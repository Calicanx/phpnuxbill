{include file="customer/header.tpl"}
<script src="/ui/ui/scripts/vue.global.js"></script>

<div class="row" id="mpesaApp">
    <div class="col-md-6 col-md-offset-3">
        <div class="panel panel-primary">
            <div class="panel-heading text-center">
                <h4 style="margin: 0; font-size: 20px;">{Lang::T('Pay with M-Pesa')}</h4>
            </div>
            <div class="panel-body" style="padding: 25px;">
                <!-- Amount Display -->
                <div class="text-center" style="margin-bottom: 25px;">
                    <h3 style="color: #666; margin:0 0 5px 0;">{$plan['name_plan']}</h3>
                    <h2 style="margin: 0; color: #2196F3; font-size: 36px;">
                        {Lang::moneyFormat($plan['price']+$tax+$add_cost)}
                    </h2>
                    <p style="margin: 5px 0 0 0; color: #666;">
                        {$plan['validity']} {$plan['validity_unit']}
                    </p>
                </div>

                <!-- Payment Form -->
                <form v-on:submit.prevent="initiatePayment">
                    <div class="form-group">
                        <input type="text"
                               class="form-control input-lg text-center"
                               v-bind:class="[phoneError ? 'is-invalid' : '']"
                               v-model="phone"
                               maxlength="10"
                               placeholder="Enter M-Pesa number (07XX XXX XXX)"
                               v-bind:disabled="isProcessing"
                               style="font-size: 18px; height: 50px;"
                               required>
                        <div class="text-danger text-center"
                             v-show="phoneError"
                             v-text="phoneError"
                             style="margin-top: 5px;">
                        </div>
                    </div>

                    <input type="hidden" name="plan_id" value="{$plan['id']}">
                    <input type="hidden" name="gateway" value="mpesa">

                    <!-- Pay Button -->
                    <button type="submit"
                            class="btn btn-success btn-lg btn-block"
                            style="font-size: 18px; padding: 12px; margin-top: 20px;"
                            v-bind:disabled="!isValidPhone || isProcessing">
                        <i class="fa fa-money"></i> {Lang::T('Pay Now')}
                    </button>
                </form>

                <!-- Status Messages -->
                <div v-show="statusMessage"
                     v-bind:class="['alert', alertClass]"
                     style="margin-top: 20px; text-align: center;">
                    <div>
                        <i v-bind:class="['fa', 'fa-2x', statusIcon]"></i>
                        <p style="margin-top: 10px;" v-text="statusMessage"></p>
                        <button v-show="paymentFailed"
                                v-on:click="resetPayment"
                                class="btn btn-primary">
                            Try Again
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const { createApp, ref, computed, watch, onBeforeUnmount } = Vue;

    const MpesaPayment = {
        delimiters: ['[[', ']]'],

        setup() {
            // State
            const phone = ref('{$_user["phonenumber"]}');
            const phoneError = ref('');
            const statusMessage = ref('');
            const isProcessing = ref(false);
            const paymentFailed = ref(false);
            const transactionId = ref(null);
            const checkInterval = ref(null);
            const attempts = ref(0);
            const MAX_ATTEMPTS = 24;

            // Computed properties
            const isValidPhone = computed(() => {
                return /^0[71][0-9]{literal}{8}{/literal}$/.test(phone.value);
            });

            const alertClass = computed(() => {
                if (paymentFailed.value) return 'alert-danger';
                if (statusMessage.value && statusMessage.value.includes('successful')) return 'alert-success';
                return 'alert-info';
            });

            const statusIcon = computed(() => {
                if (paymentFailed.value) return 'fa-exclamation-circle';
                if (statusMessage.value && statusMessage.value.includes('successful')) return 'fa-check';
                return 'fa-spinner fa-spin';
            });

            // Phone number validation
            watch(phone, (newVal) => {
                phone.value = newVal.replace(/[^0-9]/g, '');

                if (phone.value.length > 0) {
                    if (phone.value.length !== 10) {
                        phoneError.value = 'Phone number must be 10 digits';
                    } else if (!phone.value.startsWith('07') && !phone.value.startsWith('01')) {
                        phoneError.value = 'Phone number must start with 07 or 01';
                    } else {
                        phoneError.value = '';
                    }
                } else {
                    phoneError.value = '';
                }
            });

            // Methods
            const handleError = (message) => {
                stopStatusCheck();
                statusMessage.value = message;
                isProcessing.value = false;
                paymentFailed.value = true;
            };

            const resetPayment = () => {
                stopStatusCheck();
                statusMessage.value = '';
                isProcessing.value = false;
                paymentFailed.value = false;
                transactionId.value = null;
                attempts.value = 0;
            };

            const checkPaymentStatus = () => {
                if (!transactionId.value || attempts.value >= MAX_ATTEMPTS) {
                    handleError('Payment session expired. Please try again.');
                    return;
                }

                attempts.value++;
                statusMessage.value = 'Checking payment status...';

                // Return a promise for better control flow
                return $.ajax({
                    url: '{$_url}order/view/' + transactionId.value + '/check',
                    method: 'GET'
                })
                    .then((response) => {
                        try {
                            const result = JSON.parse(response);
                            switch (result.status) {
                                case 'COMPLETED':
                                    stopStatusCheck();

                                    statusMessage.value = 'Payment successful! Please wait while we sync your account...';
                                    $.ajax({
                                        url: '{$_url}home&sync=1&stoken={App::getToken()}',
                                        method: 'GET'
                                    }).then(() => {

                                        setTimeout(() => {
                                            window.location.href = '{$_url}home&mikrotik=login';
                                        }, 2000);
                                    });
                                    break;

                                case 'FAILED':
                                    handleError(result.message || 'Payment failed');
                                    break;

                                case 'PENDING':
                                    statusMessage.value = result.message || 'Waiting for payment confirmation...';
                                    // Schedule next check only if status is pending
                                    setTimeout(() => checkPaymentStatus(), 5000);
                                    break;

                                default:
                                    handleError('Invalid payment status');
                                    break;
                            }
                        } catch (error) {
                            handleError('Failed to process server response');
                        }
                    })
                    .fail(() => {
                        // On network error, retry after delay
                        statusMessage.value = 'Connection error, retrying...';
                        setTimeout(() => checkPaymentStatus(), 5000);
                    });
            };

            const startStatusCheck = () => {
                // Clear any existing check
                stopStatusCheck();
                // Reset attempts
                attempts.value = 0;
                // Start first check
                checkPaymentStatus();
            };

            const stopStatusCheck = () => {
                // We don't need checkInterval anymore since we're using recursive setTimeout
                attempts.value = MAX_ATTEMPTS; // This will prevent new checks from starting
            };

            const initiatePayment = (event) => {
                if (!isValidPhone.value) return;

                isProcessing.value = true;
                paymentFailed.value = false;
                statusMessage.value = 'Initiating payment...';
                attempts.value = 0;

                const formData = new FormData(event.target);
                formData.append('phone_number', phone.value);

                $.ajax({
                    url: '{$_url}order/buy/{$route2}/{$route3}',
                    method: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false
                })
                    .done((response) => {
                        try {
                            const result = JSON.parse(response);
                            if (result.success) {
                                transactionId.value = result.transaction_id;
                                statusMessage.value = 'Please check your phone to complete payment';
                                startStatusCheck();
                            } else {
                                throw new Error(result.message || 'Failed to initiate payment');
                            }
                        } catch (error) {
                            handleError(error.message || 'Failed to process server response');
                        }
                    })
                    .fail(() => {
                        handleError('Failed to connect to server');
                    });
            };

            // Cleanup
            onBeforeUnmount(() => {
                stopStatusCheck();
            });

            return {
                phone,
                phoneError,
                statusMessage,
                isProcessing,
                paymentFailed,
                isValidPhone,
                alertClass,
                statusIcon,
                initiatePayment,
                resetPayment
            };
        }
    };

    const app = createApp(MpesaPayment);
    app.mount('#mpesaApp');
</script>

{include file="customer/footer.tpl"}
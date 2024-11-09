{include file="customer/header.tpl"}
{*<script src="/ui/ui/scripts/vue.runtime.global.prod.js"></script>*}
<script src="/ui/ui/scripts/vue.global.js"></script>
{*<script src="/ui/ui/scripts/vue.global.js"></script>*}

<div class="row" id="mpesaApp">
    <div class="col-md-7">
        <div class="panel panel-primary panel-hovered">
            <div class="panel-heading">{Lang::T('Mpesa Payment')}</div>
            <div class="panel-body">
                <div class="payment-form">
                    <div class="alert alert-info mb-3">
                        <i class="fa fa-info-circle"></i> {Lang::T('Enter your M-Pesa phone number to complete the payment')}
                    </div>

                    <form v-on:submit.prevent="initiatePayment" class="mb-3">
                        <div class="form-group">
                            <label>{Lang::T('Phone Number')}</label>
                            <input type="text"
                                   class="form-control"
                                   v-bind:class="[phoneError ? 'is-invalid' : '']"
                                   v-model="phone"
                                   maxlength="10"
                                   placeholder="0712345678"
                                   v-bind:disabled="isProcessing"
                                   required>
                            <small class="help-block">Format: 07XXXXXXXX or 01XXXXXXXX</small>
                            <div class="text-danger" v-show="phoneError" v-text="phoneError"></div>
                        </div>

                        <input type="hidden" name="plan_id" value="{$plan['id']}">
                        <input type="hidden" name="gateway" value="mpesa">

                        <button type="submit"
                                class="btn btn-primary btn-lg btn-block"
                                v-bind:disabled="!isValidPhone || isProcessing">
                            <i class="fa fa-money"></i> {Lang::T('Pay with M-Pesa')}
                        </button>
                    </form>

                    <div v-show="statusMessage"
                         v-bind:class="['alert', alertClass]">
                        <div class="text-center">
                            <div>
                                <i v-bind:class="['fa', 'fa-2x', statusIcon]"></i>
                            </div>
                            <p class="mt-2" v-text="statusMessage"></p>
                            <button v-show="paymentFailed"
                                    v-on:click="resetPayment"
                                    class="btn btn-primary mt-2">
                                Try Again
                            </button>
                        </div>
                    </div>
                </div>

                <div class="mt-4">
                    <h4>{Lang::T('Instructions')}:</h4>
                    <ol>
                        <li>{Lang::T('Enter your M-Pesa phone number above')}</li>
                        <li>{Lang::T('Click Pay with M-Pesa button')}</li>
                        <li>{Lang::T('You will receive a payment prompt on your phone')}</li>
                        <li>{Lang::T('Enter your M-Pesa PIN to complete payment')}</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <!-- Order Summary Panel -->
    <div class="col-md-5">
        {* ... existing order summary code ... *}
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
                                    statusMessage.value = 'Payment successful! Redirecting...';
                                    setTimeout(() => {
                                        window.location.href = '{$_url}order/view/' + transactionId.value;
                                    }, 2000);
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
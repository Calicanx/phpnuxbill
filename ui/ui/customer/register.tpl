{include file="customer/header-public.tpl"}

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title" style="font-size: 20px">
                        <i class="glyphicon glyphicon-user"></i> {Lang::T('Register as New Member')}
                    </h3>
                </div>
                <div class="panel-body" style="padding: 25px;">
                    <form action="{$_url}register/post" method="post">
                        <!-- Phone Number Field -->
                        <div class="form-group">
                            <label style="font-size: 16px; font-weight: bold;">
                                {Lang::T('Phone Number')} <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-addon" style="background-color: #f8f9fa">
                                    <i class="glyphicon glyphicon-phone-alt"></i>
                                </span>
                                <input id="username"
                                       type="text"
                                       class="form-control input-lg"
                                       name="username"
                                       style="font-size: 16px; height: 50px;"
                                       placeholder="Type your phone number here without dashes (Example: 0712345678)"
                                       required>
                            </div>
                            <small class="text-muted" style="font-size: 14px">This will be your login username</small>
                        </div>

                        <!-- Hidden fields -->
                        <input type="hidden" id="fullname" name="fullname">
                        <input type="hidden" id="email" name="email">
                        <input type="hidden" name="address" value="Nyamarambe">

                        <!-- Password Field -->
                        <div class="form-group">
                            <label style="font-size: 16px; font-weight: bold;">
                                {Lang::T('Password')} <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-addon" style="background-color: #f8f9fa">
                                    <i class="glyphicon glyphicon-lock"></i>
                                </span>
                                <input type="password"
                                       class="form-control input-lg"
                                       id="password"
                                       name="password"
                                       style="font-size: 16px; height: 50px;"
                                       placeholder="Create a strong password (at least 8 characters)"
                                       required>
                            </div>
                        </div>

                        <!-- Confirm Password Field -->
                        <div class="form-group">
                            <label style="font-size: 16px; font-weight: bold;">
                                {Lang::T('Confirm Password')} <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-addon" style="background-color: #f8f9fa">
                                    <i class="glyphicon glyphicon-lock"></i>
                                </span>
                                <input type="password"
                                       class="form-control input-lg"
                                       id="cpassword"
                                       name="cpassword"
                                       style="font-size: 16px; height: 50px;"
                                       placeholder="Type your password again to confirm"
                                       required>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="form-group mt-4" style="margin-top: 30px;">
                            <button type="submit"
                                    class="btn btn-success btn-lg btn-block"
                                    style="font-size: 18px; padding: 12px;">
                                <i class="glyphicon glyphicon-check"></i> {Lang::T('Create My Account')}
                            </button>
                        </div>

                        <!-- Login Link -->
                        <div class="text-center mt-4" style="margin-top: 25px;">
                            <p style="font-size: 16px;">Already have an account?</p>
                            <a href="{$_url}login"
                               class="btn btn-primary btn-lg"
                               style="font-size: 16px;">
                                <i class="glyphicon glyphicon-log-in"></i> {Lang::T('Login to Your Account')}
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.getElementById('username').addEventListener('input', function() {
        document.getElementById('fullname').value = this.value;
        document.getElementById('email').value = this.value + '@reduzer.tech';
    });

</script>

{include file="customer/footer-public.tpl"}
{include file="customer/header-public.tpl"}

<div class="container mt-5">
    <div class="row justify-content-center">


        <div class="col-md-12 mb-3">
            <div class="alert" style="background: #1976D2; margin-bottom: 15px; border-radius: 6px; padding: 10px 15px;">
                <div class="text-center">
                    <span style="color: #FDD835; font-weight: bold; font-size: 16px;">
                        🔥 FLASH OFFER:
                    </span>
                    <span style="color: white; font-size: 16px;">
                        Create an account now and get Unlimited Internet for just
                        <span style="color: #FDD835; font-weight: bold; font-size: 18px;">Ksh 10/=</span>
                        per day!
                    </span>
                    <span style="color: #FDD835; font-weight: bold;">
                        ⚡ Limited time offer!
                    </span>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title" style="font-size: 18px">{Lang::T('Log in to Member Panel')}</h3>
                </div>
                <div class="panel-body">
                    <form action="{$_url}login/post" method="post">
                        <input type="hidden" name="csrf_token" value="{$csrf_token}">

                        <!-- Username/Phone Field -->
                        <div class="form-group">
                            <label style="font-size: 16px">
                                {if $_c['registration_username'] == 'phone'}
                                    {Lang::T('Phone Number')}
                                {elseif $_c['registration_username'] == 'email'}
                                    {Lang::T('Email')}
                                {else}
                                    {Lang::T('Username')}
                                {/if}
                            </label>
                            <div class="input-group">
                                <span class="input-group-addon" style="background-color: #f8f9fa">
                                    {if $_c['registration_username'] == 'phone'}
                                        <i class="glyphicon glyphicon-phone-alt"></i>
                                    {elseif $_c['registration_username'] == 'email'}
                                        <i class="glyphicon glyphicon-envelope"></i>
                                    {else}
                                        <i class="glyphicon glyphicon-user"></i>
                                    {/if}
                                </span>
                                <input type="text"
                                       class="form-control input-lg"
                                       name="username"
                                       placeholder="Enter your phone number here, for example: 0712345678"
                                       style="font-size: 16px; height: 46px;">
                            </div>
                        </div>

                        <!-- Password Field -->
                        <div class="form-group">
                            <label style="font-size: 16px">{Lang::T('Password')}</label>
                            <div class="input-group">
                                <span class="input-group-addon" style="background-color: #f8f9fa">
                                    <i class="glyphicon glyphicon-lock"></i>
                                </span>
                                <input type="password"
                                       class="form-control input-lg"
                                       name="password"
                                       placeholder="Type your password here"
                                       style="font-size: 16px; height: 46px;">
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="form-group mt-4">
                            <button type="submit" class="btn btn-primary btn-lg btn-block" style="font-size: 16px">
                                <i class="glyphicon glyphicon-log-in"></i> {Lang::T('Login')}
                            </button>
                        </div>

                        <!-- Additional Links -->
                        <div class="text-center mt-4" style="font-size: 16px">
                            <a href="{$_url}forgot" class="btn btn-link btn-lg" style="font-size: 16px">
                                <i class="glyphicon glyphicon-question-sign"></i> {Lang::T('Forgot Password')}
                            </a>

                            {if $_c['disable_registration'] != 'noreg'}
                                <div class="mt-3">
                                    <p>Don't have an account yet?</p>
                                    <a href="{$_url}register" class="btn btn-success btn-lg" style="font-size: 16px">
                                        <i class="glyphicon glyphicon-user"></i> {Lang::T('Register New Account')}
                                    </a>
                                </div>
                            {/if}
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Keep the modal for announcements -->
<div class="modal fade" id="HTMLModal" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true" style="font-size: 24px">&times;</span>
                </button>
            </div>
            <div class="modal-body" id="HTMLModal_konten"></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default btn-lg" data-dismiss="modal">&times;</button>
            </div>
        </div>
    </div>
</div>

{include file="customer/footer-public.tpl"}
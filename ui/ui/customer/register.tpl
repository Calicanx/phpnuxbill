{include file="customer/header-public.tpl"}
<div class="hidden-xs" style="height:100px"></div>

<div class="row">
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">{Lang::T('Registration Info')}</div>
            <div class="panel-body">
                {include file="$_path/../pages/Registration_Info.html"}
            </div>
        </div>
    </div>
    <form class="form-horizontal" action="{$_url}register/post" method="post">
        <div class="col-md-4">
            <div class="panel panel-primary">
                <div class="panel-heading">1. {Lang::T('Register as Member')}</div>
                <div class="panel-body">
                    <div class="form-container">
                        <div class="md-input-container">
                            <label>
                                {if $_c['registration_username'] == 'phone'}
                                    {Lang::T('Phone Number')}
                                {elseif $_c['registration_username'] == 'email'}
                                    {Lang::T('Email')}
                                {else}
                                    {Lang::T('Username')}
                                {/if}
                            </label>
                            <div class="input-group">
                                {if $_c['registration_username'] == 'phone'}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                {elseif $_c['registration_username'] == 'email'}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-envelope"></i></span>
                                {else}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-user"></i></span>
                                {/if}
                                <input id="username" type="text" class="form-control" name="username"
                                    placeholder="0712345678">
                            </div>
                        </div>
                        <div class="md-input-container md-float-label">
                            <label>{Lang::T('Full Name')}</label>
                            <input type="text" required class="form-control" id="fullname" value="{$fullname}"
                                name="fullname">
                        </div>
                        <div   class="md-input-container md-float-label">
                            <label  style="display: none">{Lang::T('Email')}</label>
                            <input type="hidden" class="form-control" id="email" placeholder="xxxxxxx@xxxx.xx"
                                value="{$email}" name="email">
                            <script>
                                // use the username as email but add @reduzer.tech to the end.
                                // efforts for simplifying the onboarding process
                                document.getElementById('username').addEventListener('input', function () {
                                    document.getElementById('email').value = this.value + '@reduzer.tech';
                                });
                            </script>
                        </div>
                        <div style="display: none" class="md-input-container md-float-label">
                            <label>{Lang::T('Address')}</label>
                            <input type="text" name="address" id="address" value="Nyamarambe" class="form-control">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="panel panel-primary">
                <div class="panel-heading">2. {Lang::T('Password')}</div>
                <div class="panel-body">
                    <div class="form-container">
                        <div class="md-input-container md-float-label">
                            <label>{Lang::T('Password')}</label>
                            <input type="password" required class="form-control" id="password" name="password">
                        </div>
                        <div class="md-input-container md-float-label">
                            <label>{Lang::T('Confirm Password')}</label>
                            <input type="password" required class="form-control" id="cpassword" name="cpassword">
                        </div>
                        <br>
                        <div class="btn-group btn-group-justified mb15">
                            <div class="btn-group">
                                <a href="{$_url}login" class="btn btn-warning">{Lang::T('Cancel')}</a>
                            </div>
                            <div class="btn-group">
                                <button class="btn btn-success" type="submit">{Lang::T('Register')}</button>
                            </div>
                        </div>
                        <br>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>
{include file="customer/footer-public.tpl"}
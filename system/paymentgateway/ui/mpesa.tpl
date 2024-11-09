{include file="sections/header.tpl"}
<form class="form-horizontal" method="post" role="form" action="{$_url}paymentgateway/mpesa">
    <div class="row">
        <div class="col-sm-12 col-md-12">
            <div class="panel panel-primary panel-hovered panel-stacked mb30">
                <div class="panel-heading">M-PESA</div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-md-2 control-label">Consumer Key</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" id="mpesa_consumer_key" name="mpesa_consumer_key" placeholder="Enter Consumer Key" value="{$_c['mpesa_consumer_key']}">
                            <a href="https://developer.safaricom.co.ke" target="_blank" class="help-block">https://developer.safaricom.co.ke</a>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">Consumer Secret</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" id="mpesa_consumer_secret" name="mpesa_consumer_secret" placeholder="Enter Consumer Secret" value="{$_c['mpesa_consumer_secret']}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">Business Shortcode</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" id="mpesa_business_shortcode" name="mpesa_business_shortcode" placeholder="Enter Paybill/Till Number" value="{$_c['mpesa_business_shortcode']}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">Passkey</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" id="mpesa_passkey" name="mpesa_passkey" placeholder="Enter Passkey" value="{$_c['mpesa_passkey']}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">API Environment</label>
                        <div class="col-md-6">
                            <select class="form-control" id="mpesa_base_url" name="mpesa_base_url">
                                <option value="https://sandbox.safaricom.co.ke" {if $_c['mpesa_base_url'] eq 'https://sandbox.safaricom.co.ke'}selected{/if}>Sandbox</option>
                                <option value="https://api.safaricom.co.ke" {if $_c['mpesa_base_url'] eq 'https://api.safaricom.co.ke'}selected{/if}>Production</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">Callback URL</label>
                        <div class="col-md-6">
                            <input type="text" readonly class="form-control" onclick="this.select()" value="{$_url}callback/mpesa">
                            <span class="help-block">Copy this URL and set it in your Safaricom Developer Portal</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-lg-offset-2 col-lg-10">
                            <button class="btn btn-primary waves-effect waves-light" type="submit">{Lang::T('Save Changes')}</button>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-8 col-md-offset-2">
                            <small id="emailHelp" class="form-text text-muted">
                                {Lang::T('Set Telegram Bot to get any error and notification')}
                            </small>
                            <div class="alert alert-info mt-3">
                                <strong>Note:</strong> For proper functionality:
                                <ul>
                                    <li>Ensure your Business Shortcode is activated for STK Push</li>
                                    <li>The Passkey should be obtained from your Safaricom Developer Portal</li>
                                    <li>Set up the callback URL in your Safaricom Developer Portal</li>
                                    <li>Test with the Sandbox environment first before switching to Production</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
{include file="sections/footer.tpl"}
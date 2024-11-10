{include file="customer/header.tpl"}

<div class="row">
    <div class="col-md-6 col-md-offset-3">
        {if $trx['status'] == 2}
            <div class="panel panel-success" style="border-radius: 8px; margin-bottom: 25px;">
                <div class="panel-heading text-center" style="padding: 20px;">
                    <h2 style="margin: 0; font-size: 24px;">
                        <i class="fa fa-check-circle"></i> {Lang::T('Package Activated!')}
                    </h2>
                </div>
                <div class="panel-body" style="padding: 25px;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <h3 style="margin: 0 0 10px 0;">{$plan['name_plan']}</h3>
                        <div style="font-size: 18px; color: #666;">
                            {$plan['validity']} {$plan['validity_unit']}
                        </div>
                        <div style="font-size: 24px; color: #2196F3; margin-top: 10px;">
                            {Lang::moneyFormat($trx['price'])}
                        </div>
                    </div>

                    <div class="alert alert-info" style="font-size: 16px; margin-top: 20px;">
                        <div style="margin-bottom: 15px;">
                            <strong>Connect Now</strong>
                            <ol style="margin: 10px 0 0 20px;">
                                <li>Go to <a href="http://reduzer.wifi" target="_blank">http://reduzer.wifi</a></li>
                                <li>Login with your phone number</li>
                            </ol>
                        </div>

                        <div>
                            <strong>If you can't connect</strong>
                            <ol style="margin: 10px 0 0 20px;">
                                <li>Visit <a href="http://172.16.0.4" target="_blank">dashboard</a></li>
                                <li>Click "Sync"</li>
                            </ol>
                        </div>
                    </div>

                    <div class="text-center" style="margin-top: 20px;">
                        <strong>Need help?</strong>
                        <a href="tel:0769267965" class="btn btn-primary btn-sm">
                            <i class="fa fa-phone"></i> 0769267965
                        </a>
                    </div>
                </div>
            </div>
        {else}
            <!-- Transaction Status Panel -->
            <div class="panel panel-{if $trx['status']==1}warning{elseif $trx['status']==2}success{elseif $trx['status']==3}danger{elseif $trx['status']==4}danger{else}primary{/if}"
                 style="border-radius: 8px;">
                <div class="panel-heading text-center" style="padding: 20px;">
                    <h3 style="margin: 0; font-size: 20px;">
                        {if $trx['status']==1}
                            <i class="fa fa-clock-o"></i> {Lang::T('UNPAID')}
                        {elseif $trx['status']==3}
                            <i class="fa fa-times-circle"></i> {Lang::T('FAILED')}
                        {elseif $trx['status']==4}
                            <i class="fa fa-ban"></i> {Lang::T('CANCELED')}
                        {else}
                            <i class="fa fa-question-circle"></i> {Lang::T('UNKNOWN')}
                        {/if}
                    </h3>
                </div>
                <div class="panel-body" style="padding: 20px;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <h3 style="margin: 0 0 10px 0;">{$plan['name_plan']}</h3>
                        <div style="font-size: 24px; color: #2196F3;">
                            {Lang::moneyFormat($trx['price'])}
                        </div>
                        {if $trx['status']==1}
                            <div style="margin-top: 15px; color: #666;">
                                Expires: {date($_c['date_format'], strtotime($trx['expired_date']))} {date('H:i', strtotime($trx['expired_date']))}
                            </div>
                        {/if}
                    </div>

                    {if $trx['status']==1}
                        <div class="text-center" style="margin-top: 20px;">
                            <a href="{$trx['pg_url_payment']}"
                                    {if $trx['gateway']=='midtrans'} target="_blank" {/if}
                               class="btn btn-success btn-lg" style="margin-bottom: 10px;">
                                <i class="fa fa-credit-card"></i> {Lang::T('Pay Now')}
                            </a>
                            <a href="{$_url}order/view/{$trx['id']}/cancel"
                               class="btn btn-danger btn-block"
                               onclick="return confirm('{Lang::T('Cancel it?')}')">
                                {Lang::T('Cancel')}
                            </a>
                        </div>
                    {/if}
                </div>
            </div>
        {/if}
    </div>
</div>

{include file="customer/footer.tpl"}
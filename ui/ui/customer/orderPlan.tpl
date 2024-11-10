{include file="customer/header.tpl"}

<div class="container mt-4">
    <div class="row">
        <div class="col-sm-12">
            <h2 class="text-center mb-4" style="font-size: 24px">
                <i class="glyphicon glyphicon-shopping-cart"></i> {Lang::T('Choose Your Internet Package')}
            </h2>

            {if $_c['radius_enable'] && ($_user['service_type'] == 'Others' || $_user['service_type'] == '') &&
            (Lang::arrayCount($radius_hotspot)>0)}

                <div class="row justify-content-center">
                    {foreach $radius_hotspot as $plan}
                        <div class="col-md-4 mb-4">
                            <div class="panel panel-primary" style="border: 2px solid #337ab7; border-radius: 8px;">
                                <!-- Package Header -->
                                <div class="panel-heading text-center" style="padding: 15px; border-radius: 6px 6px 0 0;">
                                    <h3 style="font-size: 22px; margin: 0;">{$plan['name_plan']}</h3>
                                </div>

                                <!-- Package Price -->
                                <div class="text-center" style="padding: 20px; background-color: #f8f9fa;">
                                    <h2 style="font-size: 32px; color: #337ab7; margin: 0;">
                                        {Lang::moneyFormat($plan['price'])}
                                        {if !empty($plan['price_old'])}
                                            <small style="text-decoration: line-through; color: red; font-size: 18px">
                                                {Lang::moneyFormat($plan['price_old'])}
                                            </small>
                                        {/if}
                                    </h2>
                                    <p style="font-size: 18px; margin: 10px 0 0;">
                                        For {$plan['validity']} {$plan['validity_unit']}
                                    </p>
                                </div>

                                <!-- Package Details -->
                                <div class="panel-body" style="padding: 20px;">
                                    {if $_c['show_bandwidth_plan'] == 'yes'}
                                        <p style="font-size: 16px; text-align: center;">
                                            <strong>Speed:</strong>
                                            <span api-get-text="{$_url}autoload_user/bw_name/{$plan['id_bw']}"></span>
                                        </p>
                                    {/if}

                                    <!-- Quick Purchase Buttons -->
                                    <div class="mt-3">
                                        {if $_c['enable_balance'] == 'yes' && $_user['balance']>=$plan['price']}
                                            <a href="{$_url}order/pay/hotspot/{$plan['id']}&stoken={App::getToken()}"
                                               onclick="return confirm('{Lang::T('Pay using your balance? Active package will be replaced')}')"
                                               class="btn btn-success btn-lg btn-block"
                                               style="font-size: 18px; margin-bottom: 10px;">
                                                <i class="glyphicon glyphicon-credit-card"></i>
                                                {Lang::T('Quick Buy with Balance')}
                                            </a>
                                        {/if}

                                        <a href="{$_url}order/gateway/hotspot/{$plan['id']}&stoken={App::getToken()}"
                                           class="btn btn-primary btn-lg btn-block"
                                           style="font-size: 18px;">
                                            <i class="glyphicon glyphicon-shopping-cart"></i>
                                            {Lang::T('Buy Now')}
                                        </a>

                                        {if $_c['enable_balance'] == 'yes' && $_c['allow_balance_transfer'] == 'yes' &&
                                        $_user['balance']>=$plan['price']}
                                            <a href="{$_url}order/send/hotspot/{$plan['id']}&stoken={App::getToken()}"
                                               class="btn btn-info btn-block mt-2"
                                               style="font-size: 16px; margin-top: 10px;">
                                                <i class="glyphicon glyphicon-gift"></i>
                                                {Lang::T('Buy for friend')}
                                            </a>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                </div>
            {/if}
        </div>
    </div>
</div>

{include file="customer/footer.tpl"}
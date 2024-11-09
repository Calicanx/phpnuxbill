<?php

/**
 *  PHP Mikrotik Billing (https://github.com/hotspotbilling/phpnuxbill/)
 *  by https://t.me/ibnux
 **/


$action = $routes['1'];
if ($action=='m-process-transaction'){ //dont mine this, just so that we don't make it obvious it is an MPESA callback
    $action = 'mpesa';
}


if (file_exists($PAYMENTGATEWAY_PATH . DIRECTORY_SEPARATOR . $action . '.php')) {
    include $PAYMENTGATEWAY_PATH . DIRECTORY_SEPARATOR . $action . '.php';
    if (function_exists($action . '_payment_notification')) {
        run_hook('callback_payment_notification'); #HOOK
        call_user_func($action . '_payment_notification');
        die();
    }
}

header('HTTP/1.1 404 Not Found');
echo 'Not Found';

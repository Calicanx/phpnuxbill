<?php

class MpesaService {
    private string $baseApiUrl;
    private string $consumerKey;
    private string $consumerSecret;
    private string $businessShortcode;
    private string $passkey;
    private array $defaultHeaders;
    private bool $isSandbox;

    public function __construct(
        string $baseApiUrl,
        string $consumerKey,
        string $consumerSecret,
        string $businessShortcode,
        string $passkey,
        bool $isSandbox = true
    ) {
        $this->baseApiUrl = rtrim($baseApiUrl, '/');
        $this->consumerKey = $consumerKey;
        $this->consumerSecret = $consumerSecret;
        $this->businessShortcode = $businessShortcode;
        $this->passkey = $passkey;
        $this->isSandbox = $isSandbox;
        $this->defaultHeaders = [
            'Content-Type: application/json'
        ];
    }

    /**
     * Initiates an STK push request to the user's phone
     *
     * @param int $amount Amount to be paid
     * @param string $phoneNumber Customer's phone number (format: 254XXXXXXXXX)
     * @param string $transactionId Unique transaction identifier
     * @param string $callbackUrl Webhook URL for payment notification
     * @param string $description Payment description
     * @return array Response from the API
     * @throws Exception
     */
    public function sendStkPush(
        int $amount,
        string $phoneNumber,
        string $transactionId,
        string $callbackUrl,
        string $description = "Payment"
    ): array {
        try {
            $timestamp = date('YmdHis');
            $password = base64_encode($this->businessShortcode . $this->passkey . $timestamp);

            $token = $this->getAccessToken();

            $payload = [
                'BusinessShortCode' => $this->businessShortcode,
                'Password' => $password,
                'Timestamp' => $timestamp,
                'TransactionType' => 'CustomerBuyGoodsOnline',
                'Amount' => $amount,
                'PartyA' => $phoneNumber,
                'PartyB' => "4240540",
                'PhoneNumber' => $phoneNumber,
                'CallBackURL' => $callbackUrl,
                'AccountReference' => $transactionId,
                'TransactionDesc' => $description
            ];

            $response = $this->makeRequest(
                'POST',
                '/mpesa/stkpush/v1/processrequest',
                $payload,
                ['Authorization: Bearer ' . $token]
            );

            // Log request and response for debugging
            $this->logDebug('STK Push request', [
                'payload' => $payload,
                'response' => $response
            ]);

            if (isset($response['errorCode']) || isset($response['errorMessage'])) {
                throw new Exception($response['errorMessage'] ?? 'STK Push failed with error code: ' . $response['errorCode']);
            }

            return $response;
        } catch (Exception $e) {
            $this->logError('STK Push failed', $e, [
                'amount' => $amount,
                'phone' => $phoneNumber,
                'reference' => $transactionId,
                'payload' => $payload ?? [],
                'callback_url' => $callbackUrl
            ]);
            throw $e;
        }
    }

    public function checkTransactionStatus(string $checkoutRequestId): array {
        try {
            $timestamp = date('YmdHis');
            $password = base64_encode($this->businessShortcode . $this->passkey . $timestamp);

            $token = $this->getAccessToken();

            $payload = [
                'BusinessShortCode' => $this->businessShortcode,
                'Password' => $password,
                'Timestamp' => $timestamp,
                'CheckoutRequestID' => $checkoutRequestId
            ];

            $response = $this->makeRequest(
                'POST',
                '/mpesa/stkpushquery/v1/query',
                $payload,
                ['Authorization: Bearer ' . $token]
            );

            // Log request and response for debugging
            $this->logDebug('Transaction status check', [
                'payload' => $payload,
                'response' => $response
            ]);

            return $response;
        } catch (Exception $e) {
            $this->logError('Status check failed', $e, ['checkoutRequestId' => $checkoutRequestId]);
            throw $e;
        }
    }

    private function getAccessToken(): string {
        try {
            $credentials = base64_encode($this->consumerKey . ':' . $this->consumerSecret);

            $response = $this->makeRequest(
                'GET',
                '/oauth/v1/generate?grant_type=client_credentials',
                [],
                ['Authorization: Basic ' . $credentials]
            );

            // Log access token request and response
            $this->logDebug('Access token request', [
                'response' => $response
            ]);

            if (!isset($response['access_token'])) {
                throw new Exception('Failed to get access token: ' . json_encode($response));
            }

            return $response['access_token'];
        } catch (Exception $e) {
            $this->logError('Access token generation failed', $e);
            throw $e;
        }
    }

    private function makeRequest(
        string $method,
        string $endpoint,
        array $payload = [],
        array $additionalHeaders = []
    ): array {
        $curl = curl_init();

        $headers = array_merge($this->defaultHeaders, $additionalHeaders);
        $url = $this->baseApiUrl . $endpoint;

        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_SSL_VERIFYPEER => !$this->isSandbox,
        ];

        if ($method === 'POST' && !empty($payload)) {
            $options[CURLOPT_POSTFIELDS] = json_encode($payload);
        }

        curl_setopt_array($curl, $options);

        $response = curl_exec($curl);
        $error = curl_error($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);

        curl_close($curl);

        // Log request details for debugging
        $this->logDebug('API request', [
            'method' => $method,
            'endpoint' => $endpoint,
            'payload' => $payload,
            'headers' => $headers,
            'http_code' => $httpCode,
            'response' => $response,
            'error' => $error
        ]);

        if ($error) {
            throw new Exception("cURL Error: " . $error);
        }

        $decodedResponse = json_decode($response, true);

        if ($httpCode >= 400) {
            throw new Exception("API Error (HTTP $httpCode): " . ($decodedResponse['errorMessage'] ?? $response));
        }

        return $decodedResponse ?: [];
    }

    private function logError(string $message, Exception $exception, array $context = []): void {
        $logMessage = sprintf(
            "[MpesaService Error] %s: %s. Context: %s",
            $message,
            $exception->getMessage(),
            json_encode($context, JSON_PRETTY_PRINT)
        );
        error_log($logMessage);
        Message::sendTelegram($logMessage);
    }

    private function logDebug(string $message, array $context = []): void {
        $logMessage = sprintf(
            "[MpesaService Debug] %s: %s",
            $message,
            json_encode($context, JSON_PRETTY_PRINT)
        );
        error_log($logMessage);
        // Optionally send debug logs to Telegram for critical monitoring
        Message::sendTelegram($logMessage);
    }
}

function mpesa_validate_config()
{
    global $config;
    if (
        empty($config['mpesa_consumer_key']) ||
        empty($config['mpesa_consumer_secret']) ||
        empty($config['mpesa_business_shortcode']) ||
        empty($config['mpesa_passkey']) ||
        empty($config['mpesa_callback_url'])
    ) {
        $missingFields = array_filter([
            'Consumer Key' => empty($config['mpesa_consumer_key']),
            'Consumer Secret' => empty($config['mpesa_consumer_secret']),
            'Business Shortcode' => empty($config['mpesa_business_shortcode']),
            'Passkey' => empty($config['mpesa_passkey']),
            'Callback URL' => empty($config['mpesa_callback_url'])
        ], fn($value) => $value);
        
        $errorMessage = "Mpesa payment gateway not configured. Missing: " . implode(', ', array_keys($missingFields));
        Message::sendTelegram($errorMessage);
        r2(U . 'order/package', 'w', Lang::T($errorMessage));
    }
}

function mpesa_show_config()
{
    global $ui, $config;
    $ui->assign('_title', 'Mpesa - Payment Gateway');
    $ui->display('mpesa.tpl');
}

function mpesa_save_config()
{
    global $admin, $_L;

    $config_fields = [
        'mpesa_consumer_key',
        'mpesa_consumer_secret',
        'mpesa_business_shortcode',
        'mpesa_passkey',
        'mpesa_base_url',
        'mpesa_callback_url'
    ];

    foreach ($config_fields as $field) {
        $value = _post($field);
        $d = ORM::for_table('tbl_appconfig')->where('setting', $field)->find_one();
        if ($d) {
            $d->value = $value;
            $d->save();
        } else {
            $d = ORM::for_table('tbl_appconfig')->create();
            $d->setting = $field;
            $d->value = $value;
            $d->save();
        }
    }

    _log('[' . $admin['username'] . ']: Mpesa ' . $_L['Settings_Saved_Successfully'], 'Admin', $admin['id']);
    r2(U . 'paymentgateway/mpesa', 's', $_L['Settings_Saved_Successfully']);
}

function encodeUrlParams(string $url): string {
    $url_parts = parse_url($url);
    if (isset($url_parts['query'])) {
        $params = explode('&', $url_parts['query']);
        $new_params = [];
        foreach ($params as $param) {
            $parts = explode('=', $param);
            $new_params[] = $parts[0] . '=' . urlencode($parts[1] ?? '');
        }
        $url_parts['query'] = implode('&', $new_params);
    }
    return $url_parts['scheme'] . '://' . $url_parts['host'] . $url_parts['path'] . (isset($url_parts['query']) ? '?' . $url_parts['query'] : '');
}

function mpesa_create_transaction($trx, $user, $phone)
{
    global $config;

    try {
        $mpesa = new MpesaService(
            $config['mpesa_base_url'],
            $config['mpesa_consumer_key'],
            $config['mpesa_consumer_secret'],
            $config['mpesa_business_shortcode'],
            $config['mpesa_passkey']
        );

        $phone = preg_replace('/[^0-9]/', '', $phone);

        if (strlen($phone) === 10) {
            $phone = '254' . substr($phone, -9);
        } elseif (strlen($phone) !== 12 || substr($phone, 0, 3) !== '254') {
            throw new Exception('Invalid phone number format. Use 254XXXXXXXXX.');
        }

        // Use the saved callback URL or fall back to the default
        $callback_url = $config['mpesa_callback_url'] ?? U . 'callback/m-process-transaction/' . $trx['id'];

        $result = $mpesa->sendStkPush(
            (int)$trx['price'],
            $phone,
            $trx['id'],
            $callback_url,
            "Reduzer"
        );

        if (!isset($result['CheckoutRequestID'])) {
            $errorMessage = isset($result['errorMessage']) 
                ? $result['errorMessage'] 
                : 'Failed to initiate payment. Please try again or contact support.';
            Message::sendTelegram("mpesa_create_transaction FAILED: \n\n" . json_encode($result, JSON_PRETTY_PRINT));
            echo json_encode([
                'success' => false,
                'transaction_id' => $trx['id'],
                'message' => $errorMessage
            ]);
            return;
        }

        $d = ORM::for_table('tbl_payment_gateway')
            ->where('username', $user['username'])
            ->where('status', 1)
            ->find_one();
        if (!$d) {
            $errorMessage = 'No active transaction found for user. Please contact support.';
            Message::sendTelegram("mpesa_create_transaction ERROR: No active transaction for user {$user['username']}");
            echo json_encode([
                'success' => false,
                'transaction_id' => $trx['id'],
                'message' => $errorMessage
            ]);
            return;
        }

        $d->gateway_trx_id = $result['CheckoutRequestID'];
        $d->pg_request = json_encode($result);
        $d->expired_date = date('Y-m-d H:i:s', strtotime('+1 hour'));
        $d->save();

        echo json_encode([
            'success' => true,
            'transaction_id' => $trx['id'],
            'message' => 'Please check your phone to complete the payment.'
        ]);
    } catch (Exception $e) {
        $message = $e->getMessage();
        Message::sendTelegram("mpesa_create_transaction ERROR: " . $message);

        $userMessage = match (true) {
            str_contains($message, 'Invalid PhoneNumber') => 'Invalid phone number. Please use format 254XXXXXXXXX.',
            str_contains($message, 'Invalid Access Token') => 'Payment service authentication failed. Please try again or contact support.',
            str_contains($message, 'Insufficient Balance') => 'Insufficient balance in the M-PESA account. Please top up and try again.',
            str_contains($message, 'cURL Error') => 'Network error. Please check your internet connection and try again.',
            default => 'Failed to initiate payment. Please try again or contact support.'
        };

        echo json_encode([
            'success' => false,
            'transaction_id' => $trx['id'],
            'message' => $userMessage,
            'debug' => $message // Include debug info for developers (optional, can be removed in production)
        ]);
    }
}

function mpesa_get_status($trx, $user)
{
    global $config;

    try {
        $mpesa = new MpesaService(
            $config['mpesa_base_url'],
            $config['mpesa_consumer_key'],
            $config['mpesa_consumer_secret'],
            $config['mpesa_business_shortcode'],
            $config['mpesa_passkey']
        );

        if ($trx['status'] == 2) {
            echo json_encode([
                'status' => 'COMPLETED',
                'message' => 'Payment successful'
            ]);
            return;
        }

        $result = $mpesa->checkTransactionStatus($trx['gateway_trx_id']);

        if (!isset($result['ResultCode'])) {
            $errorMessage = isset($result['errorMessage']) 
                ? $result['errorMessage'] 
                : 'Unable to check payment status. Please try again.';
            Message::sendTelegram("mpesa_get_status FAILED: \n\n" . json_encode($result, JSON_PRETTY_PRINT));
            echo json_encode([
                'status' => 'FAILED',
                'message' => $errorMessage
            ]);
            return;
        }

        if ($result['ResultCode'] === '0') {
            if (!Package::rechargeUser($user['id'], $trx['routers'], $trx['plan_id'], $trx['gateway'], 'MPESA')) {
                Message::sendTelegram("mpesa_get_status: Activation FAILED: \n\n" . json_encode($result, JSON_PRETTY_PRINT));
                r2(U . "order/view/" . $trx['id'], 'd', Lang::T("Failed to activate your package. Please try again later."));
            }

            $trx->pg_paid_response = json_encode($result);
            $trx->payment_method = 'MPESA';
            $trx->payment_channel = 'MPESA';
            $trx->paid_date = date('Y-m-d H:i:s');
            $trx->status = 2;
            $trx->save();
            echo json_encode([
                'status' => 'COMPLETED',
                'message' => 'Payment successful'
            ]);
            return;
        } else if (strtotime($trx['expired_date']) < time()) {
            $trx->pg_paid_response = json_encode($result);
            $trx->status = 3;
            $trx->save();

            $errorMessage = $result['ResultDesc'] ?? 'Payment request expired. Please start a new transaction.';
            echo json_encode([
                'status' => 'FAILED',
                'message' => $errorMessage,
                'result' => $result
            ]);
            return;
        } else {
            $errorMessage = $result['ResultDesc'] ?? 'Payment failed. Please try again.';
            echo json_encode([
                'status' => 'FAILED',
                'message' => $errorMessage,
                'result' => $result
            ]);
        }
    } catch (Exception $e) {
        $message = $e->getMessage();
        Message::sendTelegram("mpesa_get_status ERROR: " . $message);

        $userMessage = match (true) {
            str_contains($message, 'The transaction is being processed') => 'Payment is still being processed. Please check again shortly.',
            str_contains($message, 'Invalid Access Token') => 'Payment service authentication failed. Please try again or contact support.',
            str_contains($message, 'cURL Error') => 'Network error. Please check your internet connection and try again.',
            default => 'Unable to check payment status. Please try again or contact support.'
        };

        echo json_encode([
            'status' => 'FAILED',
            'message' => $userMessage,
            'debug' => $message // Include debug info for developers (optional, can be removed in production)
        ]);
    }
}

function mpesa_payment_notification()
{
    global $config;
    $data = file_get_contents('php://input');
    header("Content-Type: application/json");

    if (empty($data)) {
        $errorMessage = 'No callback data received from M-PESA.';
        Message::sendTelegram("mpesa_payment_notification ERROR: " . $errorMessage);
        die(json_encode(['status' => 'error', 'message' => $errorMessage]));
    }

    $json = json_decode($data, true);
    $msg = '';

    if (empty($json['Body']['stkCallback']['CheckoutRequestID'])) {
        $errorMessage = 'Invalid callback data: Missing CheckoutRequestID.';
        Message::sendTelegram("mpesa_payment_notification ERROR: \n\n" . json_encode($json, JSON_PRETTY_PRINT));
        die(json_encode(['status' => 'error', 'message' => $errorMessage]));
    }

    $trx = ORM::for_table('tbl_payment_gateway')
        ->where('gateway_trx_id', $json['Body']['stkCallback']['CheckoutRequestID'])
        ->find_one();

    if (!$trx) {
        $errorMessage = 'Transaction not found for CheckoutRequestID: ' . $json['Body']['stkCallback']['CheckoutRequestID'];
        Message::sendTelegram("mpesa_payment_notification ERROR: " . $errorMessage);
        die(json_encode(['status' => 'error', 'message' => $errorMessage]));
    }

    $user = ORM::for_table('tbl_customers')->where('username', $trx['username'])->find_one();
    if (!$user) {
        $errorMessage = 'User not found for transaction: ' . $trx['username'];
        Message::sendTelegram("mpesa_payment_notification ERROR: " . $errorMessage);
        die(json_encode(['status' => 'error', 'message' => $errorMessage]));
    }

    if ($json['Body']['stkCallback']['ResultCode'] === '0' && $trx['status'] != 2) {
        if (Package::rechargeUser($user['id'], $trx['routers'], $trx['plan_id'], $trx['gateway'], 'MPESA')) {
            $trx->pg_paid_response = json_encode($json);
            $trx->payment_method = 'MPESA';
            $trx->payment_channel = 'MPESA';
            $trx->paid_date = date('Y-m-d H:i:s');
            $trx->status = 2;
            $trx->save();
            $msg = 'Payment processed successfully';
        } else {
            $msg = 'Failed to activate package. Please contact support.';
            Message::sendTelegram("mpesa_payment_notification: Activation FAILED: \n\n" . json_encode($json, JSON_PRETTY_PRINT));
        }
    } else {
        $msg = $json['Body']['stkCallback']['ResultDesc'] ?? 'Payment not successful';
        Message::sendTelegram("mpesa_payment_notification: Payment failed: \n\n" . json_encode($json, JSON_PRETTY_PRINT));
    }

    die(json_encode([
        'status' => 'success',
        'message' => $msg,
        'ResultCode' => $json['Body']['stkCallback']['ResultCode']
    ]));
}

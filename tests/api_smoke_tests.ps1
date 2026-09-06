$ErrorActionPreference = 'Stop'
$base = 'http://localhost:5079/api'
$testPhone = "+9665000$((Get-Random -Minimum 10000 -Maximum 99999))"

function Assert-Status($response, $expected, $name) {
    if ($response.StatusCode -ne $expected) { throw "$name expected HTTP $expected, got $($response.StatusCode)" }
}

$authBody = @{ name = "API Test User"; phone = $testPhone; password = "craftflow123"; role = "customer" } | ConvertTo-Json
$auth = Invoke-WebRequest "$base/auth/register" -Method Post -ContentType 'application/json' -Body $authBody -UseBasicParsing
Assert-Status $auth 200 'register auth user'
$token = ($auth.Content | ConvertFrom-Json).token
$headers = @{ Authorization = "Bearer $token" }

$customerBody = @{ name = "API Test Customer"; phone = $testPhone } | ConvertTo-Json
$customer = Invoke-WebRequest "$base/customers" -Method Post -ContentType 'application/json' -Headers $headers -Body $customerBody -UseBasicParsing
Assert-Status $customer 201 'create customer'
$customerId = ($customer.Content | ConvertFrom-Json).id

$orderBody = @{ workshopId = 'carpentry'; customerId = $customerId; name = 'API Test Order'; description = 'automated'; material = 'wood'; length = 10; width = 20; depth = 3; status = 'Pending' } | ConvertTo-Json
$orderResponse = Invoke-WebRequest "$base/orders" -Method Post -ContentType 'application/json' -Headers $headers -Body $orderBody -UseBasicParsing
Assert-Status $orderResponse 200 'create order'
$orderId = ($orderResponse.Content | ConvertFrom-Json).order.id

$updateBody = @{ status = 'InProgress' } | ConvertTo-Json
$update = Invoke-WebRequest "$base/orders/$orderId" -Method Put -ContentType 'application/json' -Headers $headers -Body $updateBody -UseBasicParsing
Assert-Status $update 200 'update order'

$eventsBody = @{ type = 'api_test'; workshopId = 'carpentry'; orderId = [int]$orderId; payload = 'automated' } | ConvertTo-Json
$event = Invoke-WebRequest "$base/workflowevents" -Method Post -ContentType 'application/json' -Headers $headers -Body $eventsBody -UseBasicParsing
Assert-Status $event 200 'create workflow event'
$eventId = ($event.Content | ConvertFrom-Json).id

$deleteEvent = Invoke-WebRequest "$base/workflowevents/$eventId" -Method Delete -Headers $headers -UseBasicParsing
Assert-Status $deleteEvent 204 'delete workflow event'
$deleteOrder = Invoke-WebRequest "$base/orders/$orderId" -Method Delete -Headers $headers -UseBasicParsing
Assert-Status $deleteOrder 204 'delete order'
$deleteCustomer = Invoke-WebRequest "$base/customers/$customerId" -Method Delete -Headers $headers -UseBasicParsing
Assert-Status $deleteCustomer 204 'delete customer'

'API smoke tests passed: customers, orders, workflow events, update, and cleanup.'

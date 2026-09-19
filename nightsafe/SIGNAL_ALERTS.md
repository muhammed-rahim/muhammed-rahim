# Signal-loss SMS
A normal web browser cannot directly read the cellular modem's signal bars. NightSafe therefore monitors a heartbeat from the traveller device. Missing heartbeats for 90 seconds means the phone is no longer reachable by the backend; causes can include loss of mobile data, Wi-Fi loss, airplane mode, browser suspension, battery saving, or the page being closed.

The Edge Function checks stale journeys and sends a throttled SMS through Twilio. It should be scheduled about once per minute.

Required Supabase Edge Function secrets:
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
TWILIO_ACCOUNT_SID
TWILIO_AUTH_TOKEN
TWILIO_FROM

Never expose the service-role key or Twilio auth token in browser code.
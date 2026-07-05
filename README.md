# ResilientGrid dashboard

Flutter dashboard for live microgrid telemetry. The app does not generate demo values or modify sensor measurements.

## Run

Start the backend, then run:

```powershell
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
```

For a backend on another host, replace `API_URL`. Android emulators normally use `http://10.0.2.2:8000`.

The dashboard initially shows **WAITING FOR SENSOR**. It changes to live only after the backend receives telemetry.

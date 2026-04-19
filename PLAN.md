# Auto re-arm interception after every camera session

**What changes**

- After any camera session ends (stream stopped, tab hidden, page navigated, or user finishes capture), the app automatically re-arms a fresh interception breakpoint for the very next camera request — even if the website asks for the exact same camera again.
- No manual reset needed between tests. Every new request is caught cleanly, with a new timing baseline and a new diagnostic session.

**How it behaves**

- **Stream-end watcher:** The moment every track in the active MediaStream ends (via `track.onended`, `stop()`, or garbage collection), the app resets its interceptor state and waits for the next `getUserMedia` call.
- **Hard session reset:** The underlying AVCaptureSession is fully torn down between requests so no "ghost" constraints, resolutions, or device locks carry over.
- **Same-camera handling:** Even when the site requests the identical `deviceId`, the app treats it as a brand-new session — new timing log, new hardware profile snapshot, new negotiation-gap entry.
- **Re-arm indicator:** A small status chip in the HUD shows "🎯 Armed — waiting for next request" between sessions, flipping to "🔴 Intercepting" the instant a new request arrives.
- **Repeatable captures:** Auto Simulate and manual capture flows can now loop indefinitely without the user needing to reload the page or toggle modes.

**Session log**

- Each intercepted request appears as its own entry in the diagnostic timeline with a session number, so repeated requests against the same camera are easy to compare side-by-side.


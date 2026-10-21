# 05: Widget tap opens the Blister screen

**What to build:** Tapping the widget opens the app on the shown Pill Type's Blister screen with Selected Day = Today. Tapping it in the empty state opens Home and explains how to configure the widget. Follows TinyReminder's `WidgetTap` pattern (`widgetURL` plus `onOpenURL`). See `spec.md` section Tap.

**Blocked by:** 04 Lock Screen widget extension

**Status:** ready-for-agent

- [ ] The URLs (Blister screen for a Pill Type id, and the "configure" URL) are built and parsed in one place shared by the app and the widget
- [ ] The app registers its URL scheme and handles the URL with `onOpenURL`: the Blister URL resets the navigation path to `[.blister(pillTypeID:)]`; an unknown or deleted Pill Type id opens Home
- [ ] The configure URL opens Home and shows an alert: "To choose a Pill Type for this widget, touch and hold the Lock Screen, tap Customize, then tap the widget." with one OK button; strings added with `scripts/xcstrings.py`
- [ ] The widget sets the Blister URL whenever it shows a Pill Type (including the dimmed state) and the configure URL in the empty state
- [ ] Checked on iPhone 16 (iOS 18.5): tapping a configured widget opens its Blister screen on Today; tapping the empty state shows the alert on Home
- [ ] `scripts/check.sh` passes and `build_sim` builds with zero warnings

# Store readiness: F-Droid and Google Play

**Status: preparation, not submitted** (22 November 2026). Passing Flutter tests and generating an APK do not mean that an app meets either store's requirements.

## F-Droid checklist

- [x] Public source repository
- [x] FLOSS license file (GPL-3.0)
- [x] English and Portuguese metadata drafts
- [ ] Commit complete Android Gradle project; currently generated during build
- [ ] Confirm that F-Droid build infrastructure can compile the exact release tag
- [ ] Audit all Flutter/Gradle/native audio codec dependencies for FLOSS-compatible distribution
- [ ] Bundle font locally and audit `google_fonts` network behavior
- [ ] Assess any non-free network service Anti-Features
- [ ] Finalize unique Android applicationId, version code, branding and licensed app icon
- [ ] Include actual on-device screenshots (not renderings) and privacy documentation
- [ ] Submit official fdroiddata metadata and address review findings

Official guide: https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/

## Google Play checklist

- [ ] Choose stable applicationId and versioning
- [ ] Set and validate target SDK **API 36+** for phone apps under November 2026 requirements
- [ ] Create and protect permanent production signing key
- [ ] Build **signed Android App Bundle (.aab)**, not just the test APKs
- [ ] Complete Data safety declarations and public privacy policy
- [ ] Test media permissions, playback, device rotation, lock screen and accessibility
- [ ] Review online providers for authorization, copyright and distribution conditions
- [ ] Add real screenshots, licensed icon, feature graphics and developer contact
- [ ] Complete testing tracks and automated policy reviews

Official SDK policy: https://developer.android.com/google/play/requirements/target-sdk

## Release policy

Main branch runs CI and publishes **test artifacts only**. A version tag, or explicit manual release request, may create a GitHub Release **after all tests and builds succeed**. `pubspec.yaml` version and tag must agree. A passing CI run is not a promise of crash-free operation.

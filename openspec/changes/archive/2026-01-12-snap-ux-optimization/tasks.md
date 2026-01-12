# Implementation Tasks

## 1. Core Logic
- [x] 1.1 Implement `RotationSnapper` helper to calculate snapped angles.
- [x] 1.2 Implement `EdgeSnapper` helper to calculate position offsets for boundary alignment.

## 2. Integration
- [x] 2.1 Integrate rotation snapping into `SingleImageView`'s `transformGesture`.
- [x] 2.2 Integrate edge snapping into `SingleImageView`'s `dragGesture`.
- [x] 2.3 Add haptic feedback for snap events.

## 3. Verification
- [x] 3.1 Verify rotation snapping at 0, 90, 180, 270.
- [x] 3.2 Verify edge alignment snapping when parallel.
- [x] 3.3 Verify normal movement is not negatively impacted (no "sticky" feeling when moving away).

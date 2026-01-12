# Change: Snap UX Optimization

## Why
Users have difficulty aligning photos perfectly with the canvas edges, resulting in unwanted white gaps. Additionally, rotating photos to exact right angles (0, 90, 180, 270) is imprecise with touch gestures.

## What Changes
- Implement magnetic snapping when dragging photos near canvas boundaries (only when parallel).
- Implement magnetic snapping for rotation at 0, 90, 180, and 270 degrees.
- Add haptic feedback when a snap occurs.

## Impact
- **Affected Specs**: `image-interaction`
- **Affected Code**: `GridCanvasView.swift`, `SingleImageView`

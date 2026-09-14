# CP-20 — Cancel reuse-bound task

```swift
final class AvatarCell: UICollectionViewCell {
    private var imageTask: Task<Void, Never>?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
    }

    func configure(with model: Model) {
        imageTask?.cancel()
        imageTask = Task { [weak self] in
            guard let image = try? await imageLoader.image(for: model.url) else { return }
            guard !Task.isCancelled else { return }
            self?.imageView.image = image
        }
    }
}
```

In strict-concurrency projects, make actor isolation of UI and loader explicit according to the actual types; this snippet emphasizes lifetime/reuse semantics.

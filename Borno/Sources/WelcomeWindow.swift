import Cocoa

// MARK: - Window Controller (Singleton)

class WelcomeWindowController: NSObject, NSWindowDelegate {
    static let shared = WelcomeWindowController()

    private var window: NSWindow?

    func showWindow(tab: Int = 0) {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)

            if self.window == nil {
                let win = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 920, height: 620),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                win.title = "Borno (বর্ণ) — Preferences & Guide"
                win.titleVisibility = .hidden
                win.titlebarAppearsTransparent = true
                win.isReleasedWhenClosed = false
                win.isRestorable = false
                win.minSize = NSSize(width: 840, height: 560)
                win.backgroundColor = .windowBackgroundColor

                let container = ModernSplitContainerView(frame: NSRect(x: 0, y: 0, width: 920, height: 620))
                win.contentView = container
                win.setFrame(NSRect(x: 0, y: 0, width: 920, height: 620), display: true)
                win.center()
                win.delegate = self
                self.window = win
            }

            guard let win = self.window else { return }
            if let container = win.contentView as? ModernSplitContainerView {
                container.selectTab(tab)
            }
            win.setFrame(NSRect(origin: win.frame.origin, size: NSSize(width: 920, height: 620)), display: true)
            win.center()
            win.setIsVisible(true)
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
            NSApp.unhide(nil)
            NSApp.activate(ignoringOtherApps: true)
            NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

// MARK: - Modern Split Layout Container

class ModernSplitContainerView: NSView {
    private let sidebarView = ModernSidebarView()
    private let contentArea = NSView()

    private let gettingStartedView = ModernGettingStartedView()
    private let layoutView = ModernAvroLayoutView()
    private let settingsView = ModernSettingsView()
    private let aboutView = ModernAboutView()

    private var currentView: NSView?

    override init(frame: NSRect) {
        super.init(frame: frame)
        autoresizingMask = [.width, .height]
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        contentArea.translatesAutoresizingMaskIntoConstraints = false

        addSubview(sidebarView)
        addSubview(contentArea)

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            sidebarView.topAnchor.constraint(equalTo: topAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sidebarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: 240),

            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),

            contentArea.topAnchor.constraint(equalTo: topAnchor),
            contentArea.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentArea.leadingAnchor.constraint(equalTo: separator.trailingAnchor),
            contentArea.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        sidebarView.onSelectTab = { [weak self] tabIndex in
            self?.displayTab(tabIndex)
        }

        displayTab(0)
    }

    func selectTab(_ index: Int) {
        sidebarView.selectTab(index)
    }

    private func displayTab(_ index: Int) {
        currentView?.removeFromSuperview()

        let targetView: NSView
        switch index {
        case 0: targetView = gettingStartedView
        case 1: targetView = layoutView
        case 2: targetView = settingsView
        case 3: targetView = aboutView
        default: targetView = gettingStartedView
        }

        targetView.translatesAutoresizingMaskIntoConstraints = false
        contentArea.addSubview(targetView)

        NSLayoutConstraint.activate([
            targetView.topAnchor.constraint(equalTo: contentArea.topAnchor),
            targetView.bottomAnchor.constraint(equalTo: contentArea.bottomAnchor),
            targetView.leadingAnchor.constraint(equalTo: contentArea.leadingAnchor),
            targetView.trailingAnchor.constraint(equalTo: contentArea.trailingAnchor)
        ])

        currentView = targetView
    }
}

// MARK: - Native Sidebar with Frosted Glass & SF Symbols

class ModernSidebarView: NSVisualEffectView {
    var onSelectTab: ((Int) -> Void)?

    private var navButtons: [SidebarRowButton] = []
    private var selectedIndex = 0

    override init(frame: NSRect) {
        super.init(frame: frame)
        material = .sidebar
        blendingMode = .behindWindow
        state = .followsWindowActiveState
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // App Header
        let headerStack = NSStackView()
        headerStack.orientation = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .centerY
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 9
        iconView.layer?.masksToBounds = true
        if let logoPath = Bundle.main.path(forResource: "BornoGreenIcon", ofType: "png"),
           let img = NSImage(contentsOfFile: logoPath) {
            iconView.image = img
        } else {
            iconView.image = NSApp.applicationIconImage
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 38),
            iconView.heightAnchor.constraint(equalToConstant: 38)
        ])

        let titleStack = NSStackView()
        titleStack.orientation = .vertical
        titleStack.alignment = .leading
        titleStack.spacing = 1

        let appTitle = NSTextField(labelWithString: "Borno (বর্ণ)")
        appTitle.font = NSFont.systemFont(ofSize: 15, weight: .bold)
        appTitle.textColor = .labelColor

        let appSub = NSTextField(labelWithString: "Borno Bengali Keyboard")
        appSub.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        appSub.textColor = .secondaryLabelColor

        titleStack.addArrangedSubview(appTitle)
        titleStack.addArrangedSubview(appSub)

        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleStack)
        addSubview(headerStack)

        // Main Navigation Stack
        let navContainer = NSStackView()
        navContainer.orientation = .vertical
        navContainer.spacing = 2
        navContainer.alignment = .leading
        navContainer.translatesAutoresizingMaskIntoConstraints = false

        // Section 1: Preferences
        let prefLabel = makeSectionLabel("PREFERENCES")
        navContainer.addArrangedSubview(prefLabel)

        let items: [(String, String, NSColor, Int)] = [
            ("sparkles", "Getting Started", .systemBlue, 0),
            ("character.book.closed.fill", "Borno Layout", .systemIndigo, 1),
            ("gearshape.fill", "Typing Settings", .systemOrange, 2)
        ]

        for (symbol, title, color, index) in items {
            let btn = SidebarRowButton(symbol: symbol, title: title, accentColor: color, index: index)
            btn.onClick = { [weak self] idx in
                self?.selectTab(idx)
            }
            navButtons.append(btn)
            navContainer.addArrangedSubview(btn)
            btn.widthAnchor.constraint(equalTo: navContainer.widthAnchor).isActive = true
        }

        // Section 2: Application
        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 14).isActive = true
        navContainer.addArrangedSubview(spacer)

        let appSectionLabel = makeSectionLabel("SYSTEM")
        navContainer.addArrangedSubview(appSectionLabel)

        let aboutBtn = SidebarRowButton(symbol: "info.circle.fill", title: "About Borno", accentColor: .systemGreen, index: 3)
        aboutBtn.onClick = { [weak self] idx in
            self?.selectTab(idx)
        }
        navButtons.append(aboutBtn)
        navContainer.addArrangedSubview(aboutBtn)
        aboutBtn.widthAnchor.constraint(equalTo: navContainer.widthAnchor).isActive = true

        addSubview(navContainer)

        // Footer Status Pill
        let footerPill = NSView()
        footerPill.wantsLayer = true
        footerPill.layer?.cornerRadius = 12
        footerPill.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.05).cgColor
        footerPill.translatesAutoresizingMaskIntoConstraints = false

        let dot = NSView()
        dot.wantsLayer = true
        dot.layer?.cornerRadius = 3.5
        dot.layer?.backgroundColor = NSColor.systemGreen.cgColor
        dot.translatesAutoresizingMaskIntoConstraints = false

        let statusLabel = NSTextField(labelWithString: "Borno Engine · Ready")
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        footerPill.addSubview(dot)
        footerPill.addSubview(statusLabel)
        addSubview(footerPill)

        let flexibleSpacer = NSView()
        flexibleSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        flexibleSpacer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(flexibleSpacer)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            navContainer.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 24),
            navContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            navContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            flexibleSpacer.topAnchor.constraint(equalTo: navContainer.bottomAnchor),
            flexibleSpacer.leadingAnchor.constraint(equalTo: leadingAnchor),
            flexibleSpacer.trailingAnchor.constraint(equalTo: trailingAnchor),
            flexibleSpacer.bottomAnchor.constraint(equalTo: footerPill.topAnchor),

            footerPill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            footerPill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            footerPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            footerPill.heightAnchor.constraint(equalToConstant: 28),

            dot.leadingAnchor.constraint(equalTo: footerPill.leadingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: footerPill.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 7),
            dot.heightAnchor.constraint(equalToConstant: 7),

            statusLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 7),
            statusLabel.centerYAnchor.constraint(equalTo: footerPill.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: footerPill.trailingAnchor, constant: -8)
        ])

        selectTab(0)
    }

    private func makeSectionLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .tertiaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func selectTab(_ index: Int) {
        selectedIndex = index
        for btn in navButtons {
            btn.isSelected = (btn.index == index)
        }
        onSelectTab?(index)
    }
}

// MARK: - Sidebar Row Button with Color Icon Badges

class SidebarRowButton: NSView {
    let index: Int
    let accentColor: NSColor
    var onClick: ((Int) -> Void)?
    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    private let iconBadge = NSView()
    private let iconImageView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private var isHovered = false

    init(symbol: String, title: String, accentColor: NSColor, index: Int) {
        self.index = index
        self.accentColor = accentColor
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        // Squircle Icon Badge
        iconBadge.wantsLayer = true
        iconBadge.layer?.cornerRadius = 6
        iconBadge.layer?.backgroundColor = accentColor.cgColor
        iconBadge.translatesAutoresizingMaskIntoConstraints = false

        if let sysImg = NSImage(systemSymbolName: symbol, accessibilityDescription: title) {
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            iconImageView.image = sysImg.withSymbolConfiguration(config)
        }
        iconImageView.imageScaling = .scaleProportionallyUpOrDown
        iconImageView.contentTintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.addSubview(iconImageView)

        titleLabel.stringValue = title
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let contentRow = NSStackView(views: [iconBadge, titleLabel])
        contentRow.orientation = .horizontal
        contentRow.spacing = 10
        contentRow.alignment = .centerY
        contentRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentRow)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34),

            iconBadge.widthAnchor.constraint(equalToConstant: 22),
            iconBadge.heightAnchor.constraint(equalToConstant: 22),

            iconImageView.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),

            contentRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            contentRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            contentRow.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))

        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        onClick?(index)
    }

    private func updateAppearance() {
        if isSelected {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.18).cgColor
            titleLabel.textColor = .labelColor
            titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        } else if isHovered {
            layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
            titleLabel.textColor = .labelColor
            titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            titleLabel.textColor = .secondaryLabelColor
            titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        }
    }
}

// MARK: - Native Inset Grouped Card

class ModernGroupCard: NSView {
    init(content: NSView, padding: CGFloat = 16) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.6).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.2).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Tab 1: Getting Started View

class ModernGettingStartedView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let content = NSStackView()
        content.orientation = .vertical
        content.spacing = 18
        content.alignment = .leading
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        // Title & Header
        let titleStack = NSStackView()
        titleStack.orientation = .vertical
        titleStack.alignment = .leading
        titleStack.spacing = 4

        let header = NSTextField(labelWithString: "Getting Started")
        header.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        header.textColor = .labelColor

        let subtitle = NSTextField(wrappingLabelWithString: "Learn how to switch input modes and type Bengali phonetically with Borno.")
        subtitle.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitle.textColor = .secondaryLabelColor

        titleStack.addArrangedSubview(header)
        titleStack.addArrangedSubview(subtitle)
        content.addArrangedSubview(titleStack)
        titleStack.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Guide Step Cards
        let step1 = makeStepCard(
            stepNumber: "1",
            title: "Switching to Borno Keyboard",
            desc: "Press Control + Space or tap the Globe key (🌐) anytime to toggle between English and Borno.",
            badgeText: "⌃ Space  /  🌐 Globe"
        )
        content.addArrangedSubview(step1)
        step1.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        let step2 = makeStepCard(
            stepNumber: "2",
            title: "Phonetic & National Layouts",
            desc: "Type phonetically (e.g. 'ami' → 'আমি', 'bangla' → 'বাংলা') or switch to National / Bijoy layout in Settings.",
            badgeText: "Phonetic & National / Bijoy"
        )
        content.addArrangedSubview(step2)
        step2.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        let step3 = makeStepCard(
            stepNumber: "3",
            title: "Unicode & ANSI for Design Apps",
            desc: "Select ANSI mode from Settings or the Menu Bar to type directly in Adobe Illustrator, Photoshop, and legacy design tools.",
            badgeText: "Unicode & ANSI"
        )
        content.addArrangedSubview(step3)
        step3.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Live Interactive Typing Playground
        let playgroundTitle = NSTextField(labelWithString: "INTERACTIVE TEST PLAYGROUND")
        playgroundTitle.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        playgroundTitle.textColor = .secondaryLabelColor
        content.addArrangedSubview(playgroundTitle)

        let playgroundCard = makePlaygroundCard()
        content.addArrangedSubview(playgroundCard)
        playgroundCard.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        let bottomSpacer = NSView()
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        content.addArrangedSubview(bottomSpacer)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])
    }

    private func makeStepCard(stepNumber: String, title: String, desc: String, badgeText: String) -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 14
        container.alignment = .top

        // Number Badge
        let numCircle = NSView()
        numCircle.wantsLayer = true
        numCircle.layer?.cornerRadius = 14
        numCircle.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.15).cgColor
        numCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numCircle.widthAnchor.constraint(equalToConstant: 28),
            numCircle.heightAnchor.constraint(equalToConstant: 28)
        ])

        let numLabel = NSTextField(labelWithString: stepNumber)
        numLabel.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        numLabel.textColor = .controlAccentColor
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numCircle.addSubview(numLabel)
        NSLayoutConstraint.activate([
            numLabel.centerXAnchor.constraint(equalTo: numCircle.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: numCircle.centerYAnchor)
        ])

        // Text & Badge Column
        let textCol = NSStackView()
        textCol.orientation = .vertical
        textCol.alignment = .leading
        textCol.spacing = 4

        let tLabel = NSTextField(labelWithString: title)
        tLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        tLabel.textColor = .labelColor

        let dLabel = NSTextField(wrappingLabelWithString: desc)
        dLabel.font = NSFont.systemFont(ofSize: 12.5, weight: .regular)
        dLabel.textColor = .secondaryLabelColor

        let keyBadge = makeKeycapBadge(badgeText)

        textCol.addArrangedSubview(tLabel)
        textCol.addArrangedSubview(dLabel)
        textCol.addArrangedSubview(keyBadge)

        container.addArrangedSubview(numCircle)
        container.addArrangedSubview(textCol)

        return ModernGroupCard(content: container, padding: 12)
    }

    private func makePlaygroundCard() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        let desc = NSTextField(labelWithString: "Switch input method to Borno and practice typing Bengali here:")
        desc.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        desc.textColor = .secondaryLabelColor

        let textField = NSTextField()
        textField.placeholderString = "এখানে টাইপ করে পরীক্ষা করুন (যেমন: amar sonar bangla)..."
        textField.font = NSFont.systemFont(ofSize: 13.5)
        textField.isBezeled = true
        textField.bezelStyle = .roundedBezel
        textField.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(desc)
        stack.addArrangedSubview(textField)
        textField.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

        return ModernGroupCard(content: stack, padding: 12)
    }

    private func makeKeycapBadge(_ text: String) -> NSView {
        let badge = NSView()
        badge.wantsLayer = true
        badge.layer?.cornerRadius = 6
        badge.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
        badge.layer?.borderWidth = 0.8
        badge.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        badge.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: text)
        label.font = NSFont.monospacedSystemFont(ofSize: 11.5, weight: .semibold)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: badge.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -3)
        ])

        return badge
    }
}

// MARK: - Tab 2: Native Avro Layout Reference with Instant Search

class ModernAvroLayoutView: NSView {
    private let searchField = NSSearchField()
    private let segmentedControl = NSSegmentedControl()
    private let cardContainer = NSStackView()

    private var allRules: [(category: Int, eng: String, bng: String, note: String)] = []

    override init(frame: NSRect) {
        super.init(frame: frame)
        populateData()
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func populateData() {
        // Category 0: Vowels (স্বরবর্ণ)
        let vowels = [
            ("o", "অ", "Default / Root"),
            ("a", "আ", "Aa-kar (া)"),
            ("i", "ই", "Hroshwo-I (ি)"),
            ("I", "ঈ", "Dirgho-I (ী)"),
            ("u", "উ", "Hroshwo-U (ু)"),
            ("U", "ঊ", "Dirgho-U (ূ)"),
            ("rri", "ঋ", "Rri-kar (ৃ)"),
            ("e", "এ", "E-kar (ে)"),
            ("OI", "ঐ", "Oi-kar (ৈ)"),
            ("O", "ও", "O-kar (ো)"),
            ("OU", "ঔ", "Ou-kar (ৌ)")
        ]
        for (e, b, n) in vowels { allRules.append((0, e, b, n)) }

        // Category 1: Consonants (ব্যঞ্জনবর্ণ)
        let consonants = [
            ("k", "ক", ""), ("kh", "খ", ""), ("g", "গ", ""), ("gh", "ঘ", ""), ("Ng", "ঙ", ""),
            ("c", "চ", ""), ("ch", "ছ", ""), ("j", "জ", ""), ("jh", "ঝ", ""), ("NG", "ঞ", ""),
            ("T", "ট", "Hard T"), ("Th", "ঠ", "Hard Th"), ("D", "ড", "Hard D"), ("Dh", "ঢ", "Hard Dh"), ("N", "ণ", "Murdhanya N"),
            ("t", "ত", "Soft t"), ("th", "থ", "Soft th"), ("d", "দ", "Soft d"), ("dh", "ধ", "Soft dh"), ("n", "ন", "Danto N"),
            ("p", "প", ""), ("ph / f", "ফ", ""), ("b", "ব", ""), ("bh / v", "ভ", ""), ("m", "ম", ""),
            ("z / j", "য", ""), ("r", "র", ""), ("l", "ল", ""), ("sh / S", "শ", "Talobyo Sh"), ("Sh", "ষ", "Murdhanya Sh"),
            ("s", "স", "Donto S"), ("h", "হ", ""), ("R", "ড়", ""), ("Rh", "ঢ়", ""), ("y", "য়", ""),
            ("t``", "ৎ", "Khanda Ta"), ("ng / cb", "ং", "Anusvara"), (":", "ঃ", "Visarga"), ("^", "ঁ", "Chandrabindu")
        ]
        for (e, b, n) in consonants { allRules.append((1, e, b, n)) }

        // Category 2: Conjuncts & Kar (যুক্তবর্ণ)
        let conjuncts = [
            ("kkh", "ক্ষ", "ক + ষ"), ("jng", "জ্ঞ", "জ + ঞ"), ("bndh", "বন্ধ", "ন + ধ"),
            ("ngk", "ঙ্ক", "ঙ + ক"), ("ngkh", "ঙ্খ", "ঙ + খ"), ("ngg", "ঙ্গ", "ঙ + গ"), ("nggh", "ঙ্ঘ", "ঙ + ঘ"),
            ("nc", "ঞ্চ", "ঞ + চ"), ("nch", "ঞ্ছ", "ঞ + ছ"), ("nj", "ঞ্জ", "ঞ + জ"), ("njh", "ঞ্ঝ", "ঞ + ঝ"),
            ("NT", "ণ্ট", "ণ + ট"), ("NTh", "ণ্ঠ", "ণ + ঠ"), ("ND", "ণ্ড", "ণ + ড"), ("NDh", "ণ্ঢ", "ণ + ঢ"),
            ("nt", "ন্ত", "ন + ত"), ("nth", "ন্থ", "ন + থ"), ("nd", "ন্দ", "ন + দ"), ("ndh", "ন্ধ", "ন + ধ"),
            ("mp", "ম্প", "ম + প"), ("mph", "ম্ফ", "ম + ফ"), ("mb", "ম্ব", "ম + ব"), ("mbh", "ম্ভ", "ম + ভ"),
            ("sk", "স্ক", "স + ক"), ("st", "স্ত", "স + ত"), ("sp", "স্প", "স + প"), ("str", "স্ত্র", "স + ত + র"),
            ("tr", "ত্র", "ত + র"), ("kr", "ক্র", "ক + র"), ("gr", "গ্র", "গ + র"), ("k-s", "কস্", "Joiner Break (-)")
        ]
        for (e, b, n) in conjuncts { allRules.append((2, e, b, n)) }

        // Category 3: Special Keys & Numbers
        let others = [
            ("0 1 2 3 4", "০ ১ ২ ৩ ৪", "Bengali Digits"),
            ("5 6 7 8 9", "৫ ৬ ৭ ৮ ৯", "Bengali Digits"),
            ("..", "।", "Bengali Dari (দাঁড়ি)"),
            ("$$", "৳", "Taka Symbol (টাকা)"),
            ("w / v", " ব-ফলা", "যেমন: kw → ক্ব"),
            ("y / Z", " য-ফলা (্য)", "যেমন: ky → ক্য"),
            ("r", " র-ফলা (্র)", "যেমন: kr → ক্র"),
            ("rr", " রেফ (র্)", "যেমন: rrk → র্ক"),
            (",,", "্ (হসন্ত)", "Explicit Hasanta")
        ]
        for (e, b, n) in others { allRules.append((3, e, b, n)) }
    }

    private func setupUI() {
        let content = NSStackView()
        content.orientation = .vertical
        content.spacing = 16
        content.alignment = .leading
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        // Header Title
        let header = NSTextField(labelWithString: "Borno Keyboard Layout")
        header.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        header.textColor = .labelColor
        content.addArrangedSubview(header)

        let subtitle = NSTextField(wrappingLabelWithString: "Complete phonetic mapping cheat-sheet with instant search and categories.")
        subtitle.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        content.addArrangedSubview(subtitle)
        subtitle.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Search Bar & Filter Row
        let controlRow = NSStackView()
        controlRow.orientation = .horizontal
        controlRow.spacing = 12
        controlRow.alignment = .centerY
        controlRow.translatesAutoresizingMaskIntoConstraints = false

        searchField.placeholderString = "Search letter or key (e.g. kkh, ঋ, ৳)..."
        searchField.target = self
        searchField.action = #selector(filterCards)
        searchField.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.segmentCount = 4
        segmentedControl.setLabel("Vowels", forSegment: 0)
        segmentedControl.setLabel("Consonants", forSegment: 1)
        segmentedControl.setLabel("Conjuncts", forSegment: 2)
        segmentedControl.setLabel("Numbers/Other", forSegment: 3)
        segmentedControl.selectedSegment = 0
        segmentedControl.target = self
        segmentedControl.action = #selector(filterCards)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        controlRow.addArrangedSubview(segmentedControl)
        controlRow.addArrangedSubview(searchField)
        content.addArrangedSubview(controlRow)
        controlRow.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Container for rule cards
        cardContainer.orientation = .vertical
        cardContainer.spacing = 8
        cardContainer.alignment = .leading
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        content.addArrangedSubview(cardContainer)
        cardContainer.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        let bottomSpacer = NSView()
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        content.addArrangedSubview(bottomSpacer)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])

        renderFilteredCards()
    }

    @objc private func filterCards() {
        renderFilteredCards()
    }

    private func renderFilteredCards() {
        cardContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let query = searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let selectedCategory = segmentedControl.selectedSegment

        let filtered = allRules.filter { item in
            if !query.isEmpty {
                return item.eng.lowercased().contains(query) ||
                       item.bng.contains(query) ||
                       item.note.lowercased().contains(query)
            }
            return item.category == selectedCategory
        }

        if filtered.isEmpty {
            let emptyLabel = NSTextField(labelWithString: "No matches found for '\(searchField.stringValue)'")
            emptyLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            emptyLabel.textColor = .secondaryLabelColor
            cardContainer.addArrangedSubview(emptyLabel)
            return
        }

        let gridStack = NSStackView()
        gridStack.orientation = .vertical
        gridStack.spacing = 6
        gridStack.translatesAutoresizingMaskIntoConstraints = false

        for item in filtered.prefix(10) {
            let row = makeRuleRow(eng: item.eng, bng: item.bng, note: item.note)
            gridStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: gridStack.widthAnchor).isActive = true
        }

        let card = ModernGroupCard(content: gridStack, padding: 12)
        cardContainer.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: cardContainer.widthAnchor).isActive = true
    }

    private func makeRuleRow(eng: String, bng: String, note: String) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 14
        row.alignment = .centerY
        row.distribution = .fill

        // Keycap badge
        let keyBadge = NSView()
        keyBadge.wantsLayer = true
        keyBadge.layer?.cornerRadius = 5
        keyBadge.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
        keyBadge.layer?.borderWidth = 0.8
        keyBadge.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        keyBadge.translatesAutoresizingMaskIntoConstraints = false

        let kLabel = NSTextField(labelWithString: eng)
        kLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)
        kLabel.textColor = .labelColor
        kLabel.translatesAutoresizingMaskIntoConstraints = false
        keyBadge.addSubview(kLabel)
        NSLayoutConstraint.activate([
            kLabel.leadingAnchor.constraint(equalTo: keyBadge.leadingAnchor, constant: 7),
            kLabel.trailingAnchor.constraint(equalTo: keyBadge.trailingAnchor, constant: -7),
            kLabel.topAnchor.constraint(equalTo: keyBadge.topAnchor, constant: 2),
            kLabel.bottomAnchor.constraint(equalTo: keyBadge.bottomAnchor, constant: -2)
        ])

        // Arrow
        let arrow = NSTextField(labelWithString: "→")
        arrow.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        arrow.textColor = .tertiaryLabelColor

        // Bengali Output
        let bLabel = NSTextField(labelWithString: bng)
        bLabel.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        bLabel.textColor = .controlAccentColor

        // Note
        let nLabel = NSTextField(labelWithString: note)
        nLabel.font = NSFont.systemFont(ofSize: 11.5, weight: .regular)
        nLabel.textColor = .secondaryLabelColor
        nLabel.alignment = .right

        row.addArrangedSubview(keyBadge)
        row.addArrangedSubview(arrow)
        row.addArrangedSubview(bLabel)
        row.addArrangedSubview(nLabel)

        return row
    }
}

// MARK: - Tab 3: Native Settings View (Typing Preferences & Font Encoding)

class ModernSettingsView: NSView {
    private var layoutCards: [ModernModeCard] = []
    private var encodingCards: [ModernModeCard] = []
    private var modeCards: [ModernModeCard] = []

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let content = NSStackView()
        content.orientation = .vertical
        content.spacing = 16
        content.alignment = .leading
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        // Title
        let header = NSTextField(labelWithString: "Typing & Output Preferences")
        header.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        header.textColor = .labelColor
        content.addArrangedSubview(header)

        let subtitle = NSTextField(wrappingLabelWithString: "Configure keyboard layout, output font encoding (Unicode vs ANSI SutonnyMJ) and conversion modes.")
        subtitle.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        content.addArrangedSubview(subtitle)
        subtitle.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Section 1: Keyboard Layout
        let layoutSectionLabel = NSTextField(labelWithString: "KEYBOARD LAYOUT / কীবোর্ড লেআউট")
        layoutSectionLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        layoutSectionLabel.textColor = .secondaryLabelColor
        content.addArrangedSubview(layoutSectionLabel)

        let currentLayout = UserDefaults.standard.string(forKey: "BornoKeyboardLayout") ?? "avro_phonetic"

        let layoutOptions: [(id: String, title: String, badge: String?, desc: String)] = [
            ("avro_phonetic", "Borno (Phonetic)", "Default", "Avro-style phonetic transliteration (type 'amar' → 'আমার')."),
            ("National", "National / Bijoy (জাতীয়)", "Bijoy Standard", "Bangladesh National / Bijoy layout standard (type 'Av' → 'আ', 'g' → 'ম')."),
            ("Probhat", "Probhat (প্রভাত)", nil, "Standard Probhat fixed keyboard layout.")
        ]

        let layoutStack = NSStackView()
        layoutStack.orientation = .vertical
        layoutStack.spacing = 6
        layoutStack.translatesAutoresizingMaskIntoConstraints = false

        for opt in layoutOptions {
            let card = ModernModeCard(
                modeId: opt.id,
                title: opt.title,
                badgeText: opt.badge,
                description: opt.desc,
                isSelected: (currentLayout == opt.id)
            )
            card.onSelect = { [weak self] selectedId in
                self?.selectLayout(selectedId)
            }
            layoutCards.append(card)
            layoutStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: layoutStack.widthAnchor).isActive = true
        }

        let layoutGroupCard = ModernGroupCard(content: layoutStack, padding: 10)
        content.addArrangedSubview(layoutGroupCard)
        layoutGroupCard.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Section 2: Output Encoding (Unicode vs ANSI SutonnyMJ)
        let encSectionLabel = NSTextField(labelWithString: "OUTPUT ENCODING")
        encSectionLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        encSectionLabel.textColor = .secondaryLabelColor
        content.addArrangedSubview(encSectionLabel)

        let currentEncoding = UserDefaults.standard.string(forKey: "BornoOutputEncoding") ?? "Unicode"

        let encOptions: [(id: String, title: String, badge: String?, desc: String)] = [
            ("Unicode", "Unicode", "Default", "For Web, MS Word, Notes, Messenger, Figma & standard Unicode Bengali fonts (Kalpurush, Bornomala, SolaimanLipi)."),
            ("ANSI", "ANSI", nil, "Outputs direct ANSI characters for Adobe Illustrator, Photoshop, InDesign, and print publishing.")
        ]

        let encStack = NSStackView()
        encStack.orientation = .vertical
        encStack.spacing = 6
        encStack.translatesAutoresizingMaskIntoConstraints = false

        for opt in encOptions {
            let card = ModernModeCard(
                modeId: opt.id,
                title: opt.title,
                badgeText: opt.badge,
                description: opt.desc,
                isSelected: (currentEncoding == opt.id)
            )
            card.onSelect = { [weak self] selectedId in
                self?.selectEncoding(selectedId)
            }
            encodingCards.append(card)
            encStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: encStack.widthAnchor).isActive = true
        }

        let encGroupCard = ModernGroupCard(content: encStack, padding: 10)
        content.addArrangedSubview(encGroupCard)
        encGroupCard.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        // Section 3: Conversion Mode
        let modeSectionLabel = NSTextField(labelWithString: "CONVERSION BEHAVIOR / টাইপিং মোড")
        modeSectionLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        modeSectionLabel.textColor = .secondaryLabelColor
        content.addArrangedSubview(modeSectionLabel)

        let currentMode = UserDefaults.standard.string(forKey: "BornoTypingMode") ?? "phoneticFirst"

        let modes: [(id: String, title: String, badge: String?, desc: String)] = [
            ("phoneticFirst", "Phonetic-first (Standard Avro)", "Recommended", "Your exact phonetic spelling commits by default, with suggestion list instantly available."),
            ("smart", "Smart suggestions (Autocorrect)", nil, "Dictionary & auto-correction choose the best matching word on Space. Arrow keys or numbers pick alternatives."),
            ("phoneticOnly", "Phonetic-only (Pure Direct)", "Fastest", "Pure direct transliteration without suggestion popup. Maximum typing speed.")
        ]

        let modesStack = NSStackView()
        modesStack.orientation = .vertical
        modesStack.spacing = 6
        modesStack.translatesAutoresizingMaskIntoConstraints = false

        for m in modes {
            let card = ModernModeCard(
                modeId: m.id,
                title: m.title,
                badgeText: m.badge,
                description: m.desc,
                isSelected: (currentMode == m.id)
            )
            card.onSelect = { [weak self] selectedId in
                self?.selectMode(selectedId)
            }
            modeCards.append(card)
            modesStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: modesStack.widthAnchor).isActive = true
        }

        let modeGroupCard = ModernGroupCard(content: modesStack, padding: 10)
        content.addArrangedSubview(modeGroupCard)
        modeGroupCard.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true

        let bottomSpacer = NSView()
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        content.addArrangedSubview(bottomSpacer)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: 46),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func selectLayout(_ layoutId: String) {
        UserDefaults.standard.set(layoutId, forKey: "BornoKeyboardLayout")
        NotificationCenter.default.post(name: .bornoLayoutChanged, object: nil)

        for card in layoutCards {
            card.isSelected = (card.modeId == layoutId)
        }
    }

    private func selectEncoding(_ encodingId: String) {
        UserDefaults.standard.set(encodingId, forKey: "BornoOutputEncoding")
        NotificationCenter.default.post(name: .bornoEncodingChanged, object: nil)

        for card in encodingCards {
            card.isSelected = (card.modeId == encodingId)
        }
    }

    private func selectMode(_ modeId: String) {
        UserDefaults.standard.set(modeId, forKey: "BornoTypingMode")
        NotificationCenter.default.post(name: .bornoTypingModeChanged, object: nil)

        for card in modeCards {
            card.isSelected = (card.modeId == modeId)
        }
    }
}

// MARK: - Modern Mode Select Card

class ModernModeCard: NSView {
    let modeId: String
    var onSelect: ((String) -> Void)?
    var isSelected: Bool {
        didSet { updateAppearance() }
    }

    private let radioOuter = NSView()
    private let radioInner = NSView()
    private var isHovered = false

    init(modeId: String, title: String, badgeText: String?, description: String, isSelected: Bool) {
        self.modeId = modeId
        self.isSelected = isSelected
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        // Radio button
        radioOuter.wantsLayer = true
        radioOuter.layer?.cornerRadius = 9
        radioOuter.layer?.borderWidth = 1.5
        radioOuter.translatesAutoresizingMaskIntoConstraints = false

        radioInner.wantsLayer = true
        radioInner.layer?.cornerRadius = 4.5
        radioInner.layer?.backgroundColor = NSColor.white.cgColor
        radioInner.translatesAutoresizingMaskIntoConstraints = false
        radioOuter.addSubview(radioInner)

        NSLayoutConstraint.activate([
            radioOuter.widthAnchor.constraint(equalToConstant: 18),
            radioOuter.heightAnchor.constraint(equalToConstant: 18),
            radioInner.centerXAnchor.constraint(equalTo: radioOuter.centerXAnchor),
            radioInner.centerYAnchor.constraint(equalTo: radioOuter.centerYAnchor),
            radioInner.widthAnchor.constraint(equalToConstant: 9),
            radioInner.heightAnchor.constraint(equalToConstant: 9)
        ])

        // Text stack
        let textStack = NSStackView()
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = 3

        let titleRow = NSStackView()
        titleRow.orientation = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .centerY

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleRow.addArrangedSubview(titleLabel)

        if let badgeText = badgeText {
            let badge = makeBadge(badgeText)
            titleRow.addArrangedSubview(badge)
        }

        let descLabel = NSTextField(wrappingLabelWithString: description)
        descLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = .secondaryLabelColor

        textStack.addArrangedSubview(titleRow)
        textStack.addArrangedSubview(descLabel)

        let row = NSStackView(views: [radioOuter, textStack])
        row.orientation = .horizontal
        row.spacing = 12
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])

        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))

        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        onSelect?(modeId)
    }

    private func makeBadge(_ text: String) -> NSView {
        let b = NSView()
        b.wantsLayer = true
        b.layer?.cornerRadius = 5
        b.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.15).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false

        let l = NSTextField(labelWithString: text)
        l.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = .controlAccentColor
        l.translatesAutoresizingMaskIntoConstraints = false
        b.addSubview(l)

        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: b.leadingAnchor, constant: 6),
            l.trailingAnchor.constraint(equalTo: b.trailingAnchor, constant: -6),
            l.topAnchor.constraint(equalTo: b.topAnchor, constant: 2),
            l.bottomAnchor.constraint(equalTo: b.bottomAnchor, constant: -2)
        ])
        return b
    }

    private func updateAppearance() {
        if isSelected {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.12).cgColor
            layer?.borderWidth = 1.2
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            radioOuter.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
            radioOuter.layer?.borderColor = NSColor.controlAccentColor.cgColor
            radioInner.isHidden = false
        } else if isHovered {
            layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.04).cgColor
            layer?.borderWidth = 1
            layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
            radioOuter.layer?.backgroundColor = NSColor.clear.cgColor
            radioOuter.layer?.borderColor = NSColor.secondaryLabelColor.cgColor
            radioInner.isHidden = true
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderWidth = 1
            layer?.borderColor = NSColor.clear.cgColor
            radioOuter.layer?.backgroundColor = NSColor.clear.cgColor
            radioOuter.layer?.borderColor = NSColor.tertiaryLabelColor.cgColor
            radioInner.isHidden = true
        }
    }
}

// MARK: - Tab 4: Native About & Updates View

class ModernAboutView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let centerStack = NSStackView()
        centerStack.orientation = .vertical
        centerStack.alignment = .centerX
        centerStack.spacing = 14
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerStack)

        // App Icon
        let iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 20
        iconView.layer?.masksToBounds = true
        if let logoPath = Bundle.main.path(forResource: "BornoGreenIcon", ofType: "png"),
           let img = NSImage(contentsOfFile: logoPath) {
            iconView.image = img
        } else {
            iconView.image = NSApp.applicationIconImage
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 76),
            iconView.heightAnchor.constraint(equalToConstant: 76)
        ])
        centerStack.addArrangedSubview(iconView)

        // Title
        let title = NSTextField(labelWithString: "Borno (বর্ণ)")
        title.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        title.textColor = .labelColor
        centerStack.addArrangedSubview(title)

        let desc = NSTextField(wrappingLabelWithString: "Modern, native Bengali input method for macOS and Windows.\nFeaturing pure direct typing, multiple layouts, and complete Unicode + ANSI support.")
        desc.alignment = .center
        desc.font = NSFont.systemFont(ofSize: 12.5, weight: .regular)
        desc.textColor = .secondaryLabelColor
        centerStack.addArrangedSubview(desc)

        // Feature Highlight Badges
        let badgeRow = NSStackView()
        badgeRow.orientation = .horizontal
        badgeRow.spacing = 8
        badgeRow.alignment = .centerY

        badgeRow.addArrangedSubview(makePillBadge(text: "⚡️ Sub-ms Latency", color: .systemBlue))
        badgeRow.addArrangedSubview(makePillBadge(text: "🎨 ANSI Support", color: .systemPurple))
        badgeRow.addArrangedSubview(makePillBadge(text: "🔒 100% Offline", color: .systemGreen))

        centerStack.addArrangedSubview(badgeRow)

        // Info Card
        let infoCard = ModernGroupCard(content: makeInfoRows(), padding: 12)
        centerStack.addArrangedSubview(infoCard)
        infoCard.widthAnchor.constraint(equalTo: centerStack.widthAnchor).isActive = true

        // Buttons
        let btnStack = NSStackView()
        btnStack.orientation = .horizontal
        btnStack.spacing = 12

        let updateBtn = NSButton(title: "Check for Updates", target: self, action: #selector(checkForUpdates))
        updateBtn.bezelStyle = .rounded
        updateBtn.controlSize = .regular

        let gitBtn = NSButton(title: "GitHub Repository", target: self, action: #selector(openGitHub))
        gitBtn.bezelStyle = .rounded
        gitBtn.controlSize = .regular

        btnStack.addArrangedSubview(updateBtn)
        btnStack.addArrangedSubview(gitBtn)
        centerStack.addArrangedSubview(btnStack)

        let bottomSpacer = NSView()
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        centerStack.addArrangedSubview(bottomSpacer)

        NSLayoutConstraint.activate([
            centerStack.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.widthAnchor.constraint(lessThanOrEqualToConstant: 520),
            centerStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 30),
            centerStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -30),
            centerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func makePillBadge(text: String, color: NSColor) -> NSView {
        let pill = NSView()
        pill.wantsLayer = true
        pill.layer?.cornerRadius = 10
        pill.layer?.backgroundColor = color.withAlphaComponent(0.12).cgColor
        pill.translatesAutoresizingMaskIntoConstraints = false

        let lbl = NSTextField(labelWithString: text)
        lbl.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = color
        lbl.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            lbl.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            lbl.topAnchor.constraint(equalTo: pill.topAnchor, constant: 3),
            lbl.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -3)
        ])
        return pill
    }

    private func makeInfoRows() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 7
        stack.alignment = .leading

        let rows = [
            ("Version", "0.2.5 (Universal Binary)"),
            ("Encodings", "Unicode & ANSI"),
            ("Layouts", "Borno (Phonetic) · National (জাতীয়) · Probhat"),
            ("Engine", "Rust (riti) Native Core + Swift IME"),
            ("Architecture", "Apple Silicon (ARM64) + Intel (x86_64)"),
            ("Compatibility", "macOS 13.0+ & Windows 10/11"),
            ("Privacy", "100% Offline (No Telemetry / Analytics)"),
            ("Developer", "Yahia Bin Zaman"),
            ("License", "Open Source (MIT License)")
        ]

        for (k, v) in rows {
            let row = NSStackView()
            row.orientation = .horizontal
            row.distribution = .fill

            let kl = NSTextField(labelWithString: k)
            kl.font = NSFont.systemFont(ofSize: 11.5, weight: .medium)
            kl.textColor = .secondaryLabelColor

            let vl = NSTextField(labelWithString: v)
            vl.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
            vl.textColor = .labelColor
            vl.alignment = .right

            row.addArrangedSubview(kl)
            row.addArrangedSubview(vl)

            stack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        return stack
    }

    @objc private func checkForUpdates() {
        if let url = URL(string: "https://github.com/yahiabinzaman/borno-keyboard/releases") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/yahiabinzaman/borno-keyboard") {
            NSWorkspace.shared.open(url)
        }
    }
}

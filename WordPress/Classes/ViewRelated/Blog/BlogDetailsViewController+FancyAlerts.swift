import Gridicons

private var alertWorkItem: DispatchWorkItem?
private var observer: NSObjectProtocol?

extension BlogDetailsViewController {
    @objc func startObservingQuickStart() {
        observer = NotificationCenter.default.addObserver(forName: .QuickStartTourElementChangedNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.configureTableViewData()
            self?.reloadTableViewPreservingSelection()
        }
    }

    @objc func stopObservingQuickStart() {
        NotificationCenter.default.removeObserver(observer as Any)
    }

    @objc func startAlertTimer() {
        let newWorkItem = DispatchWorkItem { [weak self] in
            self?.showNoticeOrAlertAsNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: newWorkItem)
        alertWorkItem = newWorkItem
    }

    @objc func stopAlertTimer() {
        alertWorkItem?.cancel()
        alertWorkItem = nil
    }

    private var noPresentedViewControllers: Bool {
        guard let window = WordPressAppDelegate.sharedInstance().window,
            let rootViewController = window.rootViewController,
            rootViewController.presentedViewController != nil else {
            return true
        }
        return false
    }

    private func showNoticeOrAlertAsNeeded() {
        if let tourGuide = QuickStartTourGuide.find(),
            let tourToSuggest = tourGuide.tourToSuggest(for: blog) {
            tourGuide.suggest(tourToSuggest, for: blog)
        } else {
            showNotificationPrimerAlert()
        }
    }

    @objc func shouldShowQuickStartChecklist() -> Bool {
        return QuickStartTourGuide.shouldShowChecklist(for: blog)
    }

    @objc func showQuickStartV1() {
        showQuickStart()
    }

    @objc func showQuickStartCustomize() {
        showQuickStart(with: .customize)
    }

    @objc func showQuickStartGrow() {
        showQuickStart(with: .grow)
    }

    private func showQuickStart(with type: QuickStartType? = nil) {
        let checklist: UIViewController

        if let type = type, Feature.enabled(.quickStartV2) {
            checklist = QuickStartChecklistViewController(blog: blog, type: type)
        } else {
            checklist = QuickStartChecklistViewControllerV1(blog: blog)
        }

        navigationController?.showDetailViewController(checklist, sender: self)

        QuickStartTourGuide.find()?.visited(.checklist)
    }

    @objc func quickStartSectionViewModel() -> BlogDetailsSection {
        let detailFormatStr = NSLocalizedString("%1$d of %2$d completed", comment: "Format string for displaying number of compelted quickstart tutorials. %1$d is number completed, %2$d is total number of tutorials available.")

        let customizeRow = BlogDetailsRow(title: NSLocalizedString("Customize Your Site", comment: "Name of the Quick Start list that guides users through a few tasks to customize their new website."),
                                          identifier: QuickStartListTitleCell.reuseIdentifier,
                                          accessibilityIdentifier: "Customize Your Site Row",
                                          image: Gridicon.iconOfType(.customize)) { [weak self] in
                                            self?.showQuickStartCustomize()
        }
        customizeRow.quickStartIdentifier = .checklist
        if let customizeDetailCounts = QuickStartTourGuide.find()?.completionCount(of: QuickStartTourGuide.customizeListTours, for: blog) {
            customizeRow.detail = String(format: detailFormatStr, customizeDetailCounts.complete, customizeDetailCounts.total)
            customizeRow.quickStartTitleState = customizeDetailCounts.complete == customizeDetailCounts.total ? .completed : .customizeIncomplete
        }

        let growRow = BlogDetailsRow(title: NSLocalizedString("Grow Your Audience", comment: "Name of the Quick Start list that guides users through a few tasks to customize their new website."),
                                        identifier: QuickStartListTitleCell.reuseIdentifier,
                                        accessibilityIdentifier: "Grow Your Audience Row",
                                        image: Gridicon.iconOfType(.multipleUsers)) { [weak self] in
                                            self?.showQuickStartGrow()
                                        }
        growRow.quickStartIdentifier = .checklist
        if let growDetailCounts = QuickStartTourGuide.find()?.completionCount(of: QuickStartTourGuide.growListTours, for: blog) {
            growRow.detail = String(format: detailFormatStr, growDetailCounts.complete, growDetailCounts.total)
            growRow.quickStartTitleState = growDetailCounts.complete == growDetailCounts.total ? .completed : .growIncomplete
        }

        let sectionTitle = NSLocalizedString("Quick Start", comment: "Table view title for the quick start section.")
        return BlogDetailsSection(title: sectionTitle, andRows: [customizeRow, growRow])
    }

    private func showNotificationPrimerAlert() {
        guard noPresentedViewControllers else {
            return
        }

        guard !UserDefaults.standard.notificationPrimerAlertWasDisplayed else {
            return
        }

        let mainContext = ContextManager.shared.mainContext
        let accountService = AccountService(managedObjectContext: mainContext)

        guard accountService.defaultWordPressComAccount() != nil else {
            return
        }

        PushNotificationsManager.shared.loadAuthorizationStatus { [weak self] (enabled) in
            guard enabled == .notDetermined else {
                return
            }

            UserDefaults.standard.notificationPrimerAlertWasDisplayed = true

            let alert = FancyAlertViewController.makeNotificationPrimerAlertController { (controller) in
                InteractiveNotificationsManager.shared.requestAuthorization {
                    controller.dismiss(animated: true)
                }
            }
            alert.modalPresentationStyle = .custom
            alert.transitioningDelegate = self
            self?.tabBarController?.present(alert, animated: true)
        }
    }
}

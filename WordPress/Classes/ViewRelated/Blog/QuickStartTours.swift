import Gridicons

protocol QuickStartTour {
    typealias WayPoint = (element: QuickStartTourElement, description: NSAttributedString)

    var key: String { get }
    var title: String { get }
    var analyticsKey: String { get }
    var description: String { get }
    var icon: UIImage { get }
    var suggestionNoText: String { get }
    var suggestionYesText: String { get }
    var waypoints: [WayPoint] { get }
}

extension QuickStartTour {
    var waypoints: [WayPoint] {
        get {
            return []
        }
    }
}

private struct Strings {
    static let notNow = NSLocalizedString("Not now", comment: "Phrase displayed to dismiss a quick start tour suggestion.")
    static let yesShowMe = NSLocalizedString("Yes, show me", comment: "Phrase displayed to begin a quick start tour that's been suggested.")
}

struct QuickStartChecklistTour: QuickStartTour {
    let key = "quick-start-checklist-tour"
    let analyticsKey = "view_list"
    let title = NSLocalizedString("Continue with site setup", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Time to finish setting up your site! Our checklist walks you through the next steps.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.external)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let descriptionBase = NSLocalizedString("Tap %@ to see your checklist", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let descriptionTarget = NSLocalizedString("Quick Start", comment: "The menu item to tap during a guided tour.")
        return [(element: .checklist, description: descriptionBase.highlighting(phrase: descriptionTarget, icon: Gridicon.iconOfType(.listCheckmark)))]
    }()
}

struct QuickStartCreateTour: QuickStartTour {
    let key = "quick-start-create-tour"
    let analyticsKey = "create_site"
    let title = NSLocalizedString("Create your site", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Get your site up and running", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.plus)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    let waypoints: [QuickStartTour.WayPoint] = [(element: .noSuchElement, description: NSAttributedString(string: "This tour should never display as interactive."))]
}

struct QuickStartViewTour: QuickStartTour {
    let key = "quick-start-view-tour"
    let analyticsKey = "view_site"
    let title = NSLocalizedString("View your site", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Preview your new site to see what your visitors will see.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.external)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let descriptionBase = NSLocalizedString("Tap %@ to preview", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let descriptionTarget = NSLocalizedString("View Site", comment: "The menu item to tap during a guided tour.")
        return [(element: .viewSite, description: descriptionBase.highlighting(phrase: descriptionTarget, icon: Gridicon.iconOfType(.house)))]
    }()
}

struct QuickStartThemeTour: QuickStartTour {
    let key = "quick-start-theme-tour"
    let analyticsKey = "browse_themes"
    let title = NSLocalizedString("Choose a theme", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Browse all our themes to find your perfect fit.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.themes)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let descriptionBase = NSLocalizedString("Tap %@ to discover new themes", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let descriptionTarget = NSLocalizedString("Themes", comment: "The menu item to tap during a guided tour.")
        return [(element: .themes, description: descriptionBase.highlighting(phrase: descriptionTarget, icon: Gridicon.iconOfType(.themes)))]
    }()
}

struct QuickStartCustomizeTour: QuickStartTour {
    let key = "quick-start-customize-tour"
    let analyticsKey = "customize_site"
    let title = NSLocalizedString("Customize your site", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Change colors, fonts, and images for a perfectly personalized site.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.customize)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let step1DescriptionBase = NSLocalizedString("Tap %@ to continue", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step1DescriptionTarget = NSLocalizedString("Themes", comment: "The menu item to tap during a guided tour.")
        let step1: WayPoint = (element: .themes, description: step1DescriptionBase.highlighting(phrase: step1DescriptionTarget, icon: Gridicon.iconOfType(.themes)))

        let step2DescriptionBase = NSLocalizedString("Tap %@ to start personalising your site", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step2DescriptionTarget = NSLocalizedString("Customize", comment: "The menu item to tap during a guided tour.")
        let step2: WayPoint = (element: .customize, description: step2DescriptionBase.highlighting(phrase: step2DescriptionTarget, icon: Gridicon.iconOfType(.themes)))

        return [step1, step2]
    }()
}

struct QuickStartShareTour: QuickStartTour {
    let key = "quick-start-share-tour"
    let analyticsKey = "share_site"
    let title = NSLocalizedString("Share your site", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Connect to your social media accounts -- your site will automatically share new posts.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.share)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let step1DescriptionBase = NSLocalizedString("Tap %@ to continue", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step1DescriptionTarget = NSLocalizedString("Sharing", comment: "The menu item to tap during a guided tour.")
        let step1: WayPoint = (element: .sharing, description: step1DescriptionBase.highlighting(phrase: step1DescriptionTarget, icon: Gridicon.iconOfType(.share)))

        let step2DescriptionBase = NSLocalizedString("Tap the %@ to add your social media accounts", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step2DescriptionTarget = NSLocalizedString("connections", comment: "The menu item to tap during a guided tour.")
        let step2: WayPoint = (element: .connections, description: step2DescriptionBase.highlighting(phrase: step2DescriptionTarget, icon: nil))

        return [step1, step2]
    }()
}

struct QuickStartPublishTour: QuickStartTour {
    let key = "quick-start-publish-tour"
    let analyticsKey = "publish_post"
    let title = NSLocalizedString("Publish a post", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("It's time! Draft and publish your very first post.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.create)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let descriptionBase = NSLocalizedString("Tap %@ to create a new post", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        return [(element: .newpost, description: descriptionBase.highlighting(phrase: "", icon: Gridicon.iconOfType(.create)))]
    }()
}

struct QuickStartFollowTour: QuickStartTour {
    let key = "quick-start-follow-tour"
    let analyticsKey = "follow_site"
    let title = NSLocalizedString("Follow other sites", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Find sites that speak to you, and follow them to get updates when they publish.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.readerFollow)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    var waypoints: [WayPoint] = {
        let step1DescriptionBase = NSLocalizedString("Tap %@ to continue", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step1DescriptionTarget = NSLocalizedString("Reader", comment: "The menu item to tap during a guided tour.")
        let step1: WayPoint = (element: .readerTab, description: step1DescriptionBase.highlighting(phrase: step1DescriptionTarget, icon: Gridicon.iconOfType(.reader)))

        let step2DescriptionBase = NSLocalizedString("Tap %@ to continue", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step2DescriptionTarget = NSLocalizedString("Reader", comment: "The menu item to tap during a guided tour.")
        let step2: WayPoint = (element: .readerBack, description: step2DescriptionBase.highlighting(phrase: step2DescriptionTarget, icon: Gridicon.iconOfType(.chevronLeft)))

        let step3DescriptionBase = NSLocalizedString("Tap %@ to look for sites with similar interests", comment: "A step in a guided tour for quick start. %@ will be the name of the item to tap.")
        let step3DescriptionTarget = NSLocalizedString("Search", comment: "The menu item to tap during a guided tour.")
        let step3: WayPoint = (element: .readerSearch, description: step3DescriptionBase.highlighting(phrase: step3DescriptionTarget, icon: Gridicon.iconOfType(.search)))

        return [step1, step2, step3]
    }()

    func setupReaderTab() {
        guard let tabBar = WPTabBarController.sharedInstance() else {
            return
        }

        tabBar.resetReaderTab()
    }
}

struct QuickStartSiteIconTour: QuickStartTour {
    let key = "quick-start-site-icon-tour"
    let analyticsKey = "site_icon"
    let title = NSLocalizedString("Upload a site icon", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Your visitors will see your icon in their browser. Add a custom icon for a polished, pro look.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.globe)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe
}

struct QuickStartNewPageTour: QuickStartTour {
    let key = "quick-start-new-page-tour"
    let analyticsKey = "new_page"
    let title = NSLocalizedString("Create a new page", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Add a page for key content — an “About” page is a great start.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.pages)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe
}

struct QuickStartPostSharingTour: QuickStartTour {
    let key = "quick-start-post-sharing-tour"
    let analyticsKey = "post_sharing"
    let title = NSLocalizedString("Enable post sharing", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Automatically share new posts to your social media accounts.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.share)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe
}

struct QuickStartCheckStatsTour: QuickStartTour {
    let key = "quick-start-check-stats-tour"
    let analyticsKey = "check_stats"
    let title = NSLocalizedString("Check your site stats", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Keep up to date on your site’s performance.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.statsAlt)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe
}

struct QuickStartExplorePlansTour: QuickStartTour {
    let key = "quick-start-explore-plans-tour"
    let analyticsKey = "explore_plans"
    let title = NSLocalizedString("Explore plans", comment: "Title of a Quick Start Tour")
    let description = NSLocalizedString("Learn about the marketing and SEO tools in our paid plans.", comment: "Description of a Quick Start Tour")
    let icon = Gridicon.iconOfType(.plans)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe
}

private let congratsTitle = NSLocalizedString("Congrats on finishing Quick Start  🎉", comment: "Title of a Quick Start Tour")
private let congratsDescription = NSLocalizedString("doesn’t it feel good to cross things off a list?", comment: "subhead shown to users when they complete all Quick Start items")
struct QuickStartCongratulationsTour: QuickStartTour {
    let key = "quick-start-congratulations-tour"
    let analyticsKey = "congratulations"
    let title = congratsTitle
    let description = congratsDescription
    let icon = Gridicon.iconOfType(.plus)
    let suggestionNoText = Strings.notNow
    let suggestionYesText = Strings.yesShowMe

    let waypoints: [QuickStartTour.WayPoint] = [(element: .congratulations, description: NSAttributedString(string: congratsTitle))]
}

private extension String {
    func highlighting(phrase: String, icon: UIImage?) -> NSAttributedString {
        let normalParts = components(separatedBy: "%@")
        guard normalParts.count > 0 else {
            // if the provided base doesn't contain %@ then we don't know where to place the highlight
            return NSAttributedString(string: self)
        }
        let resultString = NSMutableAttributedString(string: normalParts[0])

        let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)

        let highlightStr = NSAttributedString(string: phrase, attributes: [.foregroundColor: Constants.highlightColor, .font: Constants.highlightFont])

        if let icon = icon {
            let iconAttachment = NSTextAttachment()
            iconAttachment.image = icon.imageWithTintColor(Constants.highlightColor)
            iconAttachment.bounds = CGRect(x: 0.0, y: font.descender + Constants.iconOffset, width: Constants.iconSize, height: Constants.iconSize)
            let iconStr = NSAttributedString(attachment: iconAttachment)

            switch UIView.userInterfaceLayoutDirection(for: .unspecified) {
            case .rightToLeft:
                resultString.append(highlightStr)
                resultString.append(NSAttributedString(string: " "))
                resultString.append(iconStr)
            default:
                resultString.append(iconStr)
                resultString.append(NSAttributedString(string: " "))
                resultString.append(highlightStr)
            }
        } else {
            resultString.append(highlightStr)
        }

        if normalParts.count > 1 {
            resultString.append(NSAttributedString(string: normalParts[1]))
        }

        return resultString
    }

    private enum Constants {
        static let iconOffset: CGFloat = 1.0
        static let iconSize: CGFloat = 16.0
        static let highlightColor = WPStyleGuide.lightBlue()
        static var highlightFont: UIFont {
            get {
                return WPStyleGuide.fontForTextStyle(.subheadline, fontWeight: .semibold)
            }
        }
    }
}

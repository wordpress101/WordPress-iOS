// Empty state for Giphy

struct NoResultsGiphyConfiguration {

    static func configureAsIntro(_ viewController: NoResultsViewController) {
        viewController.configure(title: .giphyPlaceholderTitle,
                                 image: Constants.imageName,
                                 subtitleImage: "giphy-attribution")

        viewController.view.layoutIfNeeded()
    }

    static func configureAsLoading(_ viewController: NoResultsViewController) {
        viewController.configure(title: .giphySearchLoading,
                                 image: Constants.imageName)

        viewController.view.layoutIfNeeded()
    }

    static func configure(_ viewController: NoResultsViewController) {
        viewController.configureForNoSearchResults(title: .giphySearchNoResult)
        viewController.view.layoutIfNeeded()
    }

    private enum Constants {
        static let imageName = "media-no-results"
    }
}

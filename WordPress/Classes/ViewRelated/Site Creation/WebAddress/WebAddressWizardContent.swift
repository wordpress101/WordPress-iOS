import UIKit

/// Contains the UI corresponding to the list of Domain suggestions.
///
final class WebAddressWizardContent: UIViewController {

    // MARK: Properties

    private struct Metrics {
        static let maxLabelWidth        = CGFloat(290)
        static let noResultsTopInset    = CGFloat(64)
    }

    /// The creator collects user input as they advance through the wizard flow.
    private let siteCreator: SiteCreator

    private let service: SiteAddressService

    private let selection: (DomainSuggestion) -> Void

    @IBOutlet
    private weak var table: UITableView!

    /// Serves as both the data source & delegate of the table view
    private(set) var tableViewProvider: TableViewProvider?

    /// Manages header visibility, keyboard management, and table view offset
    private(set) var tableViewOffsetCoordinator: TableViewOffsetCoordinator?

    /// The throttle meters requests to the remote service
    private let throttle = Scheduler(seconds: 0.5)

    /// We track the last searched value so that we can retry
    private var lastSearchQuery: String? = nil

    /// Locally tracks the network connection status via `NetworkStatusDelegate`
    private var isNetworkActive = ReachabilityUtils.isInternetReachable()

    private lazy var headerData: SiteCreationHeaderData = {
        let title = NSLocalizedString("Choose a domain name for your site",
                                      comment: "Create site, step 4. Select domain name. Title")

        let subtitle = NSLocalizedString("This is where people will find you on the internet",
                                         comment: "Create site, step 4. Select domain name. Subtitle")

        return SiteCreationHeaderData(title: title, subtitle: subtitle)
    }()

    /// This message advises the user that
    private let noResultsLabel: UILabel

    // MARK: WebAddressWizardContent

    init(creator: SiteCreator, service: SiteAddressService, selection: @escaping (DomainSuggestion) -> Void) {
        self.siteCreator = creator
        self.service = service
        self.selection = selection

        self.noResultsLabel = {
            let label = UILabel()

            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = Metrics.maxLabelWidth

            label.font = WPStyleGuide.fontForTextStyle(.title2)
            label.textAlignment = .center
            label.textColor = WPStyleGuide.greyDarken10()

            let noResultsMessage = NSLocalizedString("No available addresses matching your search", comment: "Advises the user that no Domain suggestions could be found for the search query.")
            label.text = noResultsMessage

            label.sizeToFit()

            label.isHidden = true

            return label
        }()

        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }

    // MARK: UIViewController

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewOffsetCoordinator = TableViewOffsetCoordinator(coordinated: table)

        applyTitle()
        setupBackground()
        setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeNetworkStatus()
        tableViewOffsetCoordinator?.startListeningToKeyboardNotifications()
        prepareViewIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignTextFieldResponderIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreSearchIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        tableViewOffsetCoordinator?.stopListeningToKeyboardNotifications()
        clearContent()
    }

    // MARK: Private behavior

    private func applyTitle() {
        title = NSLocalizedString("3 of 3", comment: "Site creation. Step 3. Screen title")
    }

    private func clearContent() {
        throttle.cancel()

        guard let validDataProvider = tableViewProvider as? WebAddressTableViewProvider else {
            setupTableDataProvider()
            return
        }
        validDataProvider.data = []
        tableViewOffsetCoordinator?.resetTableOffsetIfNeeded()
    }

    private func fetchAddresses(_ searchTerm: String) {
        // NB : We hard-code the domain suggestions until we have a solution for .blog subdomains `paCBwp-F-p2`
        let suggestionType: DomainsServiceRemote.DomainSuggestionType = .onlyWordPressDotCom

        service.addresses(for: searchTerm, domainSuggestionType: suggestionType) { [weak self] results in
            switch results {
            case .error(let error):
                self?.handleError(error)
            case .success(let data):
                self?.handleData(data)
            }
        }
    }

    private func handleData(_ data: [DomainSuggestion]) {
        if let validDataProvider = tableViewProvider as? WebAddressTableViewProvider {
            validDataProvider.data = data
        } else {
            setupTableDataProvider(data)
        }

        if data.isEmpty {
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.isHidden = true
        }
    }

    private func handleError(_ error: Error) {
        setupEmptyTableProvider()
    }

    private func hideSeparators() {
        table.tableFooterView = UIView(frame: .zero)
    }

    private func performSearchIfNeeded(query: String) {
        guard !query.isEmpty else {
            return
        }

        lastSearchQuery = query

        guard isNetworkActive == true else {
            setupEmptyTableProvider()
            return
        }

        throttle.throttle { [weak self] in
            self?.fetchAddresses(query)
        }
    }

    private func setupBackground() {
        view.backgroundColor = WPStyleGuide.greyLighten30()
    }

    private func setupCells() {
        let cellName = AddressCell.cellReuseIdentifier()
        let nib = UINib(nibName: cellName, bundle: nil)
        table.register(nib, forCellReuseIdentifier: cellName)

        table.register(InlineErrorRetryTableViewCell.self, forCellReuseIdentifier: InlineErrorRetryTableViewCell.cellReuseIdentifier())
    }

    private func resignTextFieldResponderIfNeeded() {
        guard WPDeviceIdentification.isiPhone(), let header = self.table.tableHeaderView as? TitleSubtitleTextfieldHeader else {
            return
        }

        let textField = header.textField
        textField.resignFirstResponder()
    }

    private func restoreSearchIfNeeded() {
        guard let header = self.table.tableHeaderView as? TitleSubtitleTextfieldHeader else {
            return
        }

        let textField = header.textField
        guard let inputText = textField.text, !inputText.isEmpty else {
            return
        }

        tableViewOffsetCoordinator?.adjustTableOffsetIfNeeded()
        performSearchIfNeeded(query: inputText)
    }

    private func prepareViewIfNeeded() {
        guard WPDeviceIdentification.isiPhone(), let header = self.table.tableHeaderView as? TitleSubtitleTextfieldHeader else {

            return
        }

        let textField = header.textField
        guard let inputText = textField.text, !inputText.isEmpty else {
            return
        }
        textField.becomeFirstResponder()
    }

    private func setupEmptyTableProvider() {
        let message: InlineErrorMessage
        if isNetworkActive {
            message = InlineErrorMessages.serverError
        } else {
            message = InlineErrorMessages.noConnection
        }

        let handler: CellSelectionHandler = { [weak self] _ in
            let retryQuery = self?.lastSearchQuery ?? ""
            self?.performSearchIfNeeded(query: retryQuery)
        }

        tableViewProvider = InlineErrorTableViewProvider(tableView: table, message: message, selectionHandler: handler)
    }

    private func setupHeaderAndNoResultsMessage() {
        let header = TitleSubtitleTextfieldHeader(frame: .zero)
        header.setTitle(headerData.title)
        header.setSubtitle(headerData.subtitle)

        header.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        header.textField.delegate = self

        let placeholderText = NSLocalizedString("Search Domains", comment: "Site creation. Seelect a domain, search field placeholder")
        let attributes = WPStyleGuide.defaultSearchBarTextAttributesSwifted(WPStyleGuide.grey())
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        header.textField.attributedPlaceholder = attributedPlaceholder

        table.tableHeaderView = header

        view.addSubview(noResultsLabel)

        NSLayoutConstraint.activate([
            header.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            header.widthAnchor.constraint(equalTo: table.widthAnchor),
            header.topAnchor.constraint(equalTo: table.topAnchor),
            noResultsLabel.widthAnchor.constraint(equalTo: header.textField.widthAnchor),
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.topAnchor.constraint(equalTo: header.textField.bottomAnchor, constant: Metrics.noResultsTopInset)
        ])

        table.tableHeaderView?.layoutIfNeeded()
        table.tableHeaderView = table.tableHeaderView
    }

    private func setupTable() {
        setupTableBackground()
        setupTableSeparator()
        setupCells()
        setupConstraints()
        setupHeaderAndNoResultsMessage()
        hideSeparators()
    }

    private func setupTableBackground() {
        table.backgroundColor = WPStyleGuide.greyLighten30()
    }

    private func setupTableSeparator() {
        table.separatorColor = WPStyleGuide.greyLighten20()
    }

    private func setupConstraints() {
        table.cellLayoutMarginsFollowReadableWidth = true

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.prevailingLayoutGuide.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.prevailingLayoutGuide.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.prevailingLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.prevailingLayoutGuide.trailingAnchor),
        ])
    }

    private func setupTableDataProvider(_ data: [DomainSuggestion] = []) {
        let handler: CellSelectionHandler = { [weak self] selectedIndexPath in
            guard let self = self, let provider = self.tableViewProvider as? WebAddressTableViewProvider else {
                return
            }

            let domainSuggestion = provider.data[selectedIndexPath.row]
            self.selection(domainSuggestion)
        }

        self.tableViewProvider = WebAddressTableViewProvider(tableView: table, data: data, selectionHandler: handler)
    }

    @objc
    private func textChanged(sender: UITextField) {
        guard let searchTerm = sender.text, searchTerm.isEmpty == false else {
            clearContent()
            return
        }

        performSearchIfNeeded(query: searchTerm)
        tableViewOffsetCoordinator?.adjustTableOffsetIfNeeded()
    }
}

// MARK: - NetworkStatusDelegate

extension WebAddressWizardContent: NetworkStatusDelegate {
    func networkStatusDidChange(active: Bool) {
        isNetworkActive = active
    }
}

// MARK: - UITextFieldDelegate

extension WebAddressWizardContent: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        tableViewOffsetCoordinator?.resetTableOffsetIfNeeded()
        return true
    }
}

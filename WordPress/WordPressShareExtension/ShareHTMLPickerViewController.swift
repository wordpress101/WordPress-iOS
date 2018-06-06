import Foundation
import CocoaLumberjack
import WordPressShared

class ShareHTMLPickerViewController: UIViewController {

    // MARK: - Public Properties

    @objc var onValueChanged: (() -> Void)?

    /// Apply Bar Button
    ///
    fileprivate lazy var applyButton: UIBarButtonItem = {
        let applyTitle = NSLocalizedString("Apply", comment: "Apply action on the app extension tags picker screen. Saves the selected tags for the post.")
        let button = UIBarButtonItem(title: applyTitle, style: .plain, target: self, action: #selector(applyWasPressed))
        button.accessibilityIdentifier = "Apply Button"
        return button
    }()

    /// Cancel Bar Button
    ///
    fileprivate lazy var cancelButton: UIBarButtonItem = {
        let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel action on the app extension tags picker screen.")
        let button = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(cancelWasPressed))
        button.accessibilityIdentifier = "Cancel Button"
        return button
    }()

    @objc fileprivate let keyboardObserver = TableViewKeyboardObserver()
    fileprivate let textView = UITextView()
    fileprivate let textViewContainer = UIView()
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    fileprivate var dataSource: HTMLPickerDataSource = HTMLPickerDataSource() {
        didSet {
            tableView.dataSource = dataSource
            reloadTableData()
        }
    }

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Interface
        setupNavigationBar()
        setupTableView()
        setupConstraints()
        keyboardObserver.tableView = tableView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.stopEditing()
        })
    }

    // MARK: - Setup Helpers

    fileprivate func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = applyButton
    }

    fileprivate func setupTableView() {
        WPStyleGuide.configureColors(for: view, andTableView: tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HTMLPickerDataSource.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        reloadTableData()
    }

    fileprivate func setupConstraints() {
        view.addSubview(tableView)
        textViewContainer.addSubview(textView)
        view.addSubview(textViewContainer)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),

            textViewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            textViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textContainerLeadingConstant),
            textViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.textContainerTrailingConstant),
            textViewContainer.bottomAnchor.constraint(equalTo: tableView.topAnchor),

            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
}

// MARK: - Actions

extension ShareHTMLPickerViewController {
    @objc func cancelWasPressed() {
        stopEditing()
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func applyWasPressed() {
        stopEditing()
//        let tags = allTags
//        if originalTags != tags {
//            onValueChanged?(tags.joined(separator: ", "))
//        }
        _ = navigationController?.popViewController(animated: true)
    }

    func suggestionTapped(cell: UITableViewCell?) {
        guard let tag = cell?.textLabel?.text else {
            return
        }
        //complete(tag: tag)
    }
}




// MARK: - UITableView Delegate Conformance

extension ShareHTMLPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Misc private helpers

fileprivate extension ShareHTMLPickerViewController {
    func stopEditing() {
        view.endEditing(true)
        resetPresentationViewUsingKeyboardFrame()
    }

    func resetPresentationViewUsingKeyboardFrame(_ keyboardFrame: CGRect = .zero) {
        guard let presentationController = navigationController?.presentationController as? ExtensionPresentationController else {
            return
        }
        presentationController.resetViewUsingKeyboardFrame(keyboardFrame)
    }

    fileprivate func reloadTableData() {
        tableView.reloadData()
        textViewContainer.layer.shadowOpacity = tableView.isEmpty ? 0 : 0.5
    }
}

// MARK: - Data Sources

private class HTMLPickerDataSource: NSObject, UITableViewDataSource {
    @objc static let cellIdentifier = "HTMLCell"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).cellIdentifier, for: indexPath)
        WPStyleGuide.Share.configureLoadingTagCell(cell)
        let row = indexPath.row
        if row == 0 {
            cell.textLabel?.text = NSLocalizedString("Plain text", comment: "Loading tags")
        }
        if row == 1 {
            cell.textLabel?.text = NSLocalizedString("Quote", comment: "Loading tags")
        }
        cell.selectionStyle = .none
        return cell
    }
}

//private protocol PostTagPickerDataSource: UITableViewDataSource {
//    var selectedTags: [String] { get set }
//    var searchQuery: String { get set }
//}
//
//private class LoadingDataSource: NSObject, PostTagPickerDataSource {
//    @objc var selectedTags = [String]()
//    @objc var searchQuery = ""
//
//    @objc static let cellIdentifier = "Loading"
//    typealias Cell = UITableViewCell
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: LoadingDataSource.cellIdentifier, for: indexPath)
//        WPStyleGuide.Share.configureLoadingTagCell(cell)
//        cell.textLabel?.text = NSLocalizedString("Loading...", comment: "Loading tags")
//        cell.selectionStyle = .none
//        return cell
//    }
//}
//
//private class FailureDataSource: NSObject, PostTagPickerDataSource {
//    @objc var selectedTags = [String]()
//    @objc var searchQuery = ""
//
//    @objc static let cellIdentifier = "Failure"
//    typealias Cell = UITableViewCell
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: FailureDataSource.cellIdentifier, for: indexPath)
//        WPStyleGuide.Share.configureLoadingTagCell(cell)
//        cell.textLabel?.text = NSLocalizedString("Couldn't load tags. Tap to retry.", comment: "Error message when tag loading failed")
//        return cell
//    }
//}
//
//private class SuggestionsDataSource: NSObject, PostTagPickerDataSource {
//    @objc static let cellIdentifier = "Default"
//    @objc let suggestions: [String]
//
//    @objc init(suggestions: [String], selectedTags: [String], searchQuery: String) {
//        self.suggestions = suggestions
//        self.selectedTags = selectedTags
//        self.searchQuery = searchQuery
//        super.init()
//    }
//
//    @objc var selectedTags: [String]
//    @objc var searchQuery: String
//
//    @objc var availableSuggestions: [String] {
//        return suggestions.filter({ !selectedTags.contains($0) })
//    }
//
//    @objc var matchedSuggestions: [String] {
//        guard !searchQuery.isEmpty else {
//            return availableSuggestions
//        }
//        return availableSuggestions.filter({ $0.localizedStandardContains(searchQuery) })
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return matchedSuggestions.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionsDataSource.cellIdentifier, for: indexPath)
//        WPStyleGuide.Share.configureTagCell(cell)
//        let match = matchedSuggestions[indexPath.row]
//        cell.textLabel?.attributedText = highlight(searchQuery, in: match)
//        return cell
//    }
//
//    @objc func highlight(_ search: String, in string: String) -> NSAttributedString {
//        let highlighted = NSMutableAttributedString(string: string)
//        let range = (string as NSString).localizedStandardRange(of: search)
//        guard range.location != NSNotFound else {
//            return highlighted
//        }
//        let font = UIFont.systemFont(ofSize: WPStyleGuide.tableviewTextFont().pointSize, weight: .bold)
//        highlighted.setAttributes([.font: font], range: range)
//        return highlighted
//    }
//}

// MARK: - Constants

extension ShareHTMLPickerViewController {
    struct Constants {
        static let textViewTopBottomInset: CGFloat = 11.0
        static let textContainerLeadingConstant: CGFloat = -1
        static let textContainerTrailingConstant: CGFloat = 1
    }
}

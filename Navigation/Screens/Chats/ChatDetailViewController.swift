import UIKit

final class ChatDetailViewController: UIViewController {
    struct Message {
        let id: UUID
        let text: String
        let isOutgoing: Bool
        let date: Date
    }

    private let titleText: String
    private let roomID: String
    private let chatService: FirebaseChatServiceProtocol

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let composerView = UIView()
    private let inputContainerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let emojiButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private var composerBottomConstraint: NSLayoutConstraint?

    private var messages: [Message] = []
    private var refreshTimer: Timer?

    init(
        title: String,
        roomID: String,
        chatService: FirebaseChatServiceProtocol = FirebaseChatService()
    ) {
        self.titleText = title
        self.roomID = roomID
        self.chatService = chatService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleText
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupTableView()
        setupComposer()
        setupKeyboardHandling()
        loadMessages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPolling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopPolling()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        view.addSubview(tableView)
    }

    private func setupComposer() {
        composerView.translatesAutoresizingMaskIntoConstraints = false
        composerView.backgroundColor = .clear

        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = StyleGuide.Colors.card
        inputContainerView.layer.cornerRadius = 20
        inputContainerView.layer.borderWidth = 1
        inputContainerView.layer.borderColor = StyleGuide.Colors.border.cgColor

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = StyleGuide.Fonts.body(16)
        textView.textColor = StyleGuide.Colors.textPrimary
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 9, left: 2, bottom: 9, right: 2)
        textView.delegate = self

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = L10n.tr("chat.input.placeholder")
        placeholderLabel.font = StyleGuide.Fonts.body(16)
        placeholderLabel.textColor = StyleGuide.Colors.textSecondary

        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        emojiButton.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        emojiButton.tintColor = StyleGuide.Colors.textSecondary
        emojiButton.backgroundColor = StyleGuide.Colors.backgroundSecondary
        emojiButton.layer.cornerRadius = 14
        emojiButton.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = StyleGuide.Colors.inverseText
        sendButton.backgroundColor = StyleGuide.Colors.accent
        sendButton.layer.cornerRadius = 16
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        view.addSubview(composerView)
        composerView.addSubview(inputContainerView)
        inputContainerView.addSubview(emojiButton)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(textView)
        textView.addSubview(placeholderLabel)

        composerBottomConstraint = composerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        composerBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: composerView.topAnchor),

            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            inputContainerView.topAnchor.constraint(equalTo: composerView.topAnchor, constant: 8),
            inputContainerView.leadingAnchor.constraint(equalTo: composerView.leadingAnchor, constant: 12),
            inputContainerView.trailingAnchor.constraint(equalTo: composerView.trailingAnchor, constant: -12),
            inputContainerView.bottomAnchor.constraint(equalTo: composerView.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            emojiButton.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 8),
            emojiButton.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -6),
            emojiButton.widthAnchor.constraint(equalToConstant: 28),
            emojiButton.heightAnchor.constraint(equalToConstant: 28),

            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -6),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),

            textView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -4),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 6),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10)
        ])
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardInView = view.convert(endFrame, from: nil)
        let overlap = max(view.bounds.maxY - keyboardInView.minY - view.safeAreaInsets.bottom, 0)
        composerBottomConstraint?.constant = -overlap

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curveRaw << 16),
            animations: { self.view.layoutIfNeeded() }
        )
    }

    @objc private func emojiTapped() {
        let emojis = ["😀", "😂", "😍", "🔥", "👍", "❤️", "👏", "🥳", "🤝"]
        let sheet = UIAlertController(title: L10n.tr("chat.emoji.pick"), message: nil, preferredStyle: .actionSheet)
        emojis.forEach { emoji in
            sheet.addAction(UIAlertAction(title: emoji, style: .default, handler: { [weak self] _ in
                self?.insertEmoji(emoji)
            }))
        }
        sheet.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = emojiButton
            popover.sourceRect = emojiButton.bounds
        }
        present(sheet, animated: true)
    }

    private func insertEmoji(_ emoji: String) {
        textView.text += emoji
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func startPolling() {
        stopPolling()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.loadMessages()
        }
    }

    private func stopPolling() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func loadMessages() {
        guard let token = FirebaseSessionStorage.shared.token,
              let currentUser = FirebaseSessionStorage.shared.user?.email else {
            return
        }

        Task {
            let apiMessages = (try? await chatService.fetchMessages(roomID: roomID, token: token)) ?? []
            let mapped = apiMessages.map {
                Message(
                    id: UUID(),
                    text: $0.text,
                    isOutgoing: FirebaseChatService.normalizedUserID($0.sender) == FirebaseChatService.normalizedUserID(currentUser),
                    date: $0.sentAt
                )
            }

            await MainActor.run {
                self.messages = mapped
                self.tableView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }

    @objc private func sendTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard let token = FirebaseSessionStorage.shared.token,
              let currentUser = FirebaseSessionStorage.shared.user?.email else { return }

        textView.text = ""
        placeholderLabel.isHidden = false

        Task {
            do {
                try await chatService.sendMessage(roomID: roomID, sender: currentUser, text: text, token: token)
                await MainActor.run {
                    self.loadMessages()
                }
            } catch {
                await MainActor.run {
                    self.textView.text = text
                    self.placeholderLabel.isHidden = true
                }
            }
        }
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let lastRow = messages.count - 1
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: animated)
    }
}

extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as! ChatMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

extension ChatDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private final class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"

    private let bubble = UIView()
    private let messageLabel = UILabel()
    private let container = UIView()
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        container.translatesAutoresizingMaskIntoConstraints = false
        bubble.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.font = StyleGuide.Fonts.body(16, weight: .regular)
        bubble.layer.cornerRadius = 16

        contentView.addSubview(container)
        container.addSubview(bubble)
        bubble.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            bubble.topAnchor.constraint(equalTo: container.topAnchor),
            bubble.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor, multiplier: 0.74),

            messageLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12)
        ])

        leadingConstraint = bubble.leadingAnchor.constraint(equalTo: container.leadingAnchor)
        trailingConstraint = bubble.trailingAnchor.constraint(equalTo: container.trailingAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: ChatDetailViewController.Message) {
        messageLabel.text = message.text
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false

        if message.isOutgoing {
            bubble.backgroundColor = StyleGuide.Colors.accent
            messageLabel.textColor = StyleGuide.Colors.inverseText
            leadingConstraint = bubble.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 48)
            trailingConstraint = bubble.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        } else {
            bubble.backgroundColor = StyleGuide.Colors.card
            messageLabel.textColor = StyleGuide.Colors.textPrimary
            leadingConstraint = bubble.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            trailingConstraint = bubble.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -48)
        }
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
}

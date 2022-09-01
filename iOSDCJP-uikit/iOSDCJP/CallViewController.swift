//
//  CallViewController.swift
//  iOSDCJP
//
//  Created by Abdulhakim Ajetunmobi on 29/08/2022.
//

import UIKit
import NexmoClient

final class CallViewController: UIViewController {
    
    private let jwt: String
    private var call: NXMCall?
    private var isCalling = false {
        didSet {
            toggleCalling()
        }
    }
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 24
        sv.isHidden = true
        return sv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "接続中..."
        label.textAlignment = .center
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.layer.borderWidth = 1
        tf.textAlignment = .center
        tf.layer.cornerRadius = 15
        tf.placeholder = "電話番号"
        return tf
    }()
    
    private let callButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "コール"
        configuration.image = UIImage(systemName: "phone.circle.fill")
        configuration.imagePadding = 10
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(jwt: String) {
        self.jwt = jwt
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        NXMClient.shared.login(withAuthToken: jwt)
        NXMClient.shared.setDelegate(self)
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(statusLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(callButton)
        
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 32),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 240),
            stackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24)
        ])
        
        navigationItem.title = "iOSDC Japan 2022"
        navigationItem.hidesBackButton = true
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
    }
    
    @objc private func callButtonTapped() {
        if isCalling {
            endCall()
        } else {
            startCall()
        }
    }
    
    private func toggleCalling() {
        DispatchQueue.main.async { [self] in
            if isCalling {
                statusLabel.text = "\(textField.text!) と通話中"
                callButton.setTitle("コール終了", for: .normal)
                callButton.tintColor = .systemRed
            } else {
                statusLabel.text = "\(NXMClient.shared.user!.name) として接続"
                callButton.setTitle("コール", for: .normal)
                callButton.tintColor = .systemBlue
            }
        }
    }
    
    private func startCall() {
        NXMClient.shared.serverCall(withCallee: textField.text!, customData: nil) { [self] error, call in
            if call != nil {
                self.call = call
                isCalling = true
            }
        }
    }
    
    private func endCall() {
        self.call?.hangup()
        self.call = nil
        self.isCalling = false
    }
}

extension CallViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        DispatchQueue.main.async { [self] in
            switch status {
            case .connected:
                statusLabel.text = "\(client.user!.name) として接続"
                stackView.isHidden = false
            case .connecting:
                statusLabel.text = "接続中..."
            case .disconnected:
                statusLabel.text = "切断されました"
                navigationController?.popToRootViewController(animated: true)
                stackView.isHidden = true
            @unknown default:
                fatalError()
            }
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        print(error)
    }
    
}

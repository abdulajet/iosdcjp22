//
//  ViewController.swift
//  iOSDCJP
//
//  Created by Abdulhakim Ajetunmobi on 29/08/2022.
//

import UIKit
import NexmoClient
import AVFoundation

class ViewController: UIViewController {
    
    private let baseUrl = "https://api-eu.vonage.com/v1/neru/i/neru-febe6726-iosdcjp-dev"
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.layer.borderWidth = 1
        tf.textAlignment = .center
        tf.layer.cornerRadius = 15
        tf.placeholder = "ユーザ名"
        return tf
    }()
    
    private let loginButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "ログイン"
        configuration.image = UIImage(systemName: "person.circle.fill")
        configuration.imagePadding = 10
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let image = UIImage(named: "iosdcjp")
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 24
        return sv
    }()
    
    private let progressView: UIActivityIndicatorView = {
        let pv = UIActivityIndicatorView(style: .large)
        pv.isHidden = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    private var isLoading = false {
        didSet {
            toggleLoading()
        }
    }
    
    private var jwt = "" {
        didSet {
            showCallScreen()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionsIfNeeded()
        setUpView()
    }
    
    private func requestPermissionsIfNeeded() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                print("Microphone permissions \(isGranted)")
            }
        }
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addSubview(progressView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(loginButton)
        
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 240),
            textField.heightAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 170),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            loginButton.widthAnchor.constraint(equalToConstant: 240),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 240),
            
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        navigationItem.title = "iOSDC Japan 2022"
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func toggleLoading() {
        DispatchQueue.main.async { [self] in
            progressView.isHidden = !isLoading
            stackView.isHidden = isLoading
        }
    }
    
    private func showCallScreen() {
        self.navigationController?.pushViewController(CallViewController(jwt: self.jwt), animated: true)
    }
    
    @objc private func loginButtonTapped() {
        isLoading = true
        Task {
            var username = textField.text!
            if username.isEmpty { username = "Alice" }
            await login(username: username)
            let jwt = await getJwt(username: username)
            self.jwt = jwt
        }
    }
    
    private func login(username: String) async {
        var request = URLRequest(url: URL(string: "\(baseUrl)/createuser")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(User(username: username))
        let _ = try! await URLSession.shared.data(for: request)
    }
    
    private func getJwt(username: String) async -> String {
        var request = URLRequest(url: URL(string: "\(baseUrl)/jwt?username=\(username)")!)
        request.httpMethod = "GET"
        let (data, _) = try! await URLSession.shared.data(for: request)
        return try! JSONDecoder().decode(JWTData.self, from: data).jwt
    }

}

struct User: Codable {
    let username: String
}

struct JWTData: Codable {
    let jwt: String
}


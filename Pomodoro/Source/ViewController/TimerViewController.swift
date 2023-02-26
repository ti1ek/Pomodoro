//
//  CircularProgressView.swift
//  Pomodoro
//
//  Created by Tilek Koszhanov on 2/26/23.
//

import UIKit

class TimerViewController: UIViewController {
    
    let workTime = 25 // in seconds
    let restTime = 10 // in seconds
    
    var timeRemaining = 0.0
    var timer: Timer?
    var isPaused = true
    var isWorking = true
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .medium)
        label.text = "00:00"
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let ringProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemRed.cgColor
        layer.lineWidth = 10
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.strokeStart = -CGFloat.pi/2
        layer.strokeEnd = 0
        return layer
    }()
    
    private let ringBackgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.gray.cgColor
        layer.lineWidth = 10
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.strokeStart = -CGFloat.pi/2
        layer.strokeEnd = 1
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(countdownLabel)
        view.addSubview(playPauseButton)
        
        // Add ring progress layer to view
        view.layer.addSublayer(ringBackgroundLayer)
        view.layer.addSublayer(ringProgressLayer)
        
        constraintSetup()
        
        timeRemaining = Double(workTime)
        countdownLabel.text = formatTime(timeRemaining)
        countdownLabel.textColor = .systemRed
        
        // Add target to button
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
        // Set up shape for ring progress layer
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let radius = min(view.bounds.width, view.bounds.height) / 2 - 20
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat.pi * 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ringProgressLayer.path = path.cgPath
        ringBackgroundLayer.path = path.cgPath
    }
    
    func constraintSetup() {
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: countdownLabel.bottomAnchor, constant: 32)
        ])
    }
    
    @objc func playPauseButtonTapped() {
        if isPaused {
            // start timer
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
            isPaused = false
            playPauseButton
                .setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            // pause timer
            timer?.invalidate()
            isPaused = true
            playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    @objc func timerTick() {
        timeRemaining -= 0.01
        countdownLabel.text = formatTime(timeRemaining)
        
        // Calculate progress and update ring progress layer
        let progress = 1.0 - Float(timeRemaining) / Float(isWorking ? workTime : restTime)
        let fromValue = ringProgressLayer.presentation()?.strokeEnd ?? ringProgressLayer.strokeEnd
        let toValue = CGFloat(progress)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.01
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        ringProgressLayer.add(animation, forKey: "strokeAnimation")
        
        if timeRemaining <= 0 {
            switchMode()
            
            let animation = CABasicAnimation(keyPath: "strokeColor")
            animation.fromValue = ringProgressLayer.strokeColor
            if isWorking {
                ringProgressLayer.strokeColor = UIColor.systemRed.cgColor
                animation.toValue = UIColor.systemRed.cgColor
                playPauseButton.tintColor = .systemRed
            } else {
                ringProgressLayer.strokeColor = UIColor.systemGreen.cgColor
                animation.toValue = UIColor.systemGreen.cgColor
                playPauseButton.tintColor = .systemGreen
            }
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ringProgressLayer.add(animation, forKey: "strokeColorAnimation")
        }
    }
    
    func switchMode() {
        if isWorking {
            timeRemaining = Double(restTime)
            isWorking = false
            countdownLabel.textColor = .systemGreen
        } else {
            timeRemaining = Double(workTime)
            isWorking = true
            countdownLabel.textColor = .systemRed
        }
        
        countdownLabel.text = formatTime(timeRemaining)
        playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        isPaused = true
        timer?.invalidate()
    }
    
    func formatTime(_ time: Double) -> String {
        let seconds = Int(time)
        let milliseconds = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        return String(format: "%02d:%02d", seconds, milliseconds)
    }
}

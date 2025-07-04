//
//  portal.swift
//  Battery
//
//  Created by Serhiy Mytrovtsiy on 16/03/2023
//  Using Swift 5.0
//  Running on macOS 13.2
//
//  Copyright © 2023 Serhiy Mytrovtsiy. All rights reserved.
//

import Cocoa
import Kit

internal class Portal: NSStackView, Portal_p {
    var name: String
    
    private let batteryView: BatteryView = BatteryView()
    private var levelField: NSTextField = ValueField(frame: NSRect.zero, "")
    private var timeField: NSTextField = ValueField(frame: NSRect.zero, "")
    private var chargingField: NSTextField = ValueField(frame: NSRect.zero, "")
    
    private var initialized: Bool = false
    
    private var timeFormat: String {
        Store.shared.string(key: "\(self.name)_timeFormat", defaultValue: "short")
    }
    
    public init(_ module: ModuleType) {
        self.name = module.stringValue
        
        super.init(frame: NSRect.zero)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.layer?.cornerRadius = 3
        
        self.orientation = .vertical
        self.distribution = .fillEqually
        self.spacing = Constants.Popup.spacing*2
        self.edgeInsets = NSEdgeInsets(
            top: Constants.Popup.spacing*2,
            left: Constants.Popup.spacing*2,
            bottom: Constants.Popup.spacing*2,
            right: Constants.Popup.spacing*2
        )
        self.addArrangedSubview(PortalHeader(name))
        
        let box: NSStackView = NSStackView()
        box.heightAnchor.constraint(equalToConstant: 15).isActive = true
        box.orientation = .horizontal
        box.distribution = .fillEqually
        box.spacing = 0
        box.edgeInsets = NSEdgeInsets(top: 0, left: Constants.Popup.spacing*2, bottom: 0, right: Constants.Popup.spacing*2)
        
        self.levelField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        self.levelField.alignment = .left
        self.chargingField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        self.chargingField.alignment = .center
        self.timeField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        self.timeField.alignment = .right
        
        let leftStack = NSStackView(views: [self.levelField])
        leftStack.orientation = .horizontal
        leftStack.alignment = .leading
        let centerStack = NSStackView(views: [self.chargingField])
        centerStack.orientation = .horizontal
        centerStack.alignment = .centerX
        let rightStack = NSStackView(views: [self.timeField])
        rightStack.orientation = .horizontal
        rightStack.alignment = .trailing
        
        box.addArrangedSubview(leftStack)
        box.addArrangedSubview(NSView())
        box.addArrangedSubview(centerStack)
        box.addArrangedSubview(NSView())
        box.addArrangedSubview(rightStack)
        
        self.addArrangedSubview(self.batteryView)
        self.addArrangedSubview(box)
        
        self.heightAnchor.constraint(equalToConstant: Constants.Popup.portalHeight).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateLayer() {
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    
    public func loadCallback(_ value: Battery_Usage) {
        DispatchQueue.main.async(execute: {
            self.levelField.stringValue = "\(Int(abs(value.level) * 100))%"
            
            var seconds: Double = 0
            if value.timeToEmpty != -1 && value.timeToEmpty != 0 {
                seconds = Double((value.isBatteryPowered ? value.timeToEmpty : value.timeToCharge)*60)
            }
            self.timeField.stringValue = seconds != 0 ? seconds.printSecondsToHoursMinutesSeconds(short: self.timeFormat == "short") : ""
            
            self.batteryView.setValue(abs(value.level), lowPowerMode: value.lowPowerModeEnabled)
            
            if !value.isBatteryPowered {
                self.chargingField.stringValue = value.isCharging ? localizedString("Charging") : localizedString("Connected")
            } else if self.chargingField.stringValue != "" {
                self.chargingField.stringValue = ""
            }
            
            self.initialized = true
        })
    }
}

//
//  popup.swift
//  Battery
//
//  Created by Serhiy Mytrovtsiy on 06/06/2020.
//  Using Swift 5.0.
//  Running on macOS 10.15.
//
//  Copyright © 2020 Serhiy Mytrovtsiy. All rights reserved.
//

import Cocoa
import Kit

internal class Popup: PopupWrapper {
    private let dashboardHeight: CGFloat = 90
    private var detailsHeight: CGFloat = (22 * 4) + Constants.Popup.separatorHeight
    private let batteryHeight: CGFloat = (22 * 7) + Constants.Popup.separatorHeight
    private let adapterHeight: CGFloat = (22 * 4) + Constants.Popup.separatorHeight
    private let processHeight: CGFloat = 22
    
    private var dashboardView: NSView? = nil
    private var dashboardBatteryView: BatteryView? = nil
    private var detailsView: NSView? = nil
    private var batteryView: NSView? = nil
    private var adapterView: NSView? = nil
    private var processesView: NSView? = nil
    
    private var levelField: NSTextField? = nil
    private var sourceField: NSTextField? = nil
    private var timeLabelField: NSTextField? = nil
    private var timeField: NSTextField? = nil
    private var healthField: NSTextField? = nil
    private var capacityField: NSTextField? = nil
    private var cyclesField: NSTextField? = nil
    private var lastChargeField: NSTextField? = nil
    
    private var amperageField: NSTextField? = nil
    private var voltageField: NSTextField? = nil
    private var batteryPowerField: NSTextField? = nil
    private var temperatureField: NSTextField? = nil
    
    private var powerField: NSTextField? = nil
    private var chargingStateField: NSTextField? = nil
    private var chargingCurrentField: NSTextField? = nil
    private var chargingVoltageField: NSTextField? = nil
    
    private var processes: ProcessesView? = nil
    private var processesInitialized: Bool = false
    
    private var colorState: Bool = false
    
    private var numberOfProcesses: Int {
        Store.shared.int(key: "\(self.title)_processes", defaultValue: 8)
    }
    private var processesHeight: CGFloat {
        (self.processHeight*CGFloat(self.numberOfProcesses)) + (self.numberOfProcesses == 0 ? 0 : Constants.Popup.separatorHeight + 22)
    }
    private var timeFormat: String {
        Store.shared.string(key: "\(self.title)_timeFormat", defaultValue: "short")
    }
    
    public init(_ module: ModuleType) {
        super.init(module, frame: NSRect(x: 0, y: 0, width: Constants.Popup.width, height: 0))
        
        self.spacing = 0
        self.orientation = .vertical
        
        self.colorState = Store.shared.bool(key: "\(self.title)_color", defaultValue: self.colorState)
        
        self.addArrangedSubview(self.initDashboard())
        self.addArrangedSubview(self.initDetails())
        self.addArrangedSubview(self.initBattery())
        self.addArrangedSubview(self.initProcesses())
        
        self.recalculateHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func disappear() {
        self.processes?.setLock(false)
    }
    
    private func recalculateHeight() {
        var h: CGFloat = 0
        self.arrangedSubviews.forEach { v in
            if let v = v as? NSStackView {
                h += v.arrangedSubviews.map({ $0.bounds.height }).reduce(0, +)
            } else {
                h += v.bounds.height
            }
        }
        if self.frame.size.height != h {
            self.setFrameSize(NSSize(width: self.frame.width, height: h))
            self.sizeCallback?(self.frame.size)
        }
    }
    
    private func initDashboard() -> NSView {
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.dashboardHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        let container: NSView = NSView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: self.dashboardHeight))
        
        self.dashboardBatteryView = BatteryView(frame: NSRect(
            x: Constants.Popup.margins,
            y: Constants.Popup.margins,
            width: view.frame.width - (Constants.Popup.margins*2),
            height: view.frame.height - (Constants.Popup.margins*2)
        ))
        container.addSubview(self.dashboardBatteryView!)
        
        view.addSubview(container)
        
        return view
    }
    
    private func initDetails() -> NSView {
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.detailsHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        let separator = separatorView(localizedString("Details"), origin: NSPoint(x: 0, y: self.detailsHeight-Constants.Popup.separatorHeight), width: self.frame.width)
        let container: NSStackView = NSStackView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: separator.frame.origin.y))
        container.orientation = .vertical
        container.spacing = 0
        
        self.levelField = popupRow(container, title: "\(localizedString("Level")):", value: "").1
        self.sourceField = popupRow(container, title: "\(localizedString("Source")):", value: "").1
        let t = self.labelValue(container, title: "\(localizedString("Time")):", value: "")
        self.timeLabelField = t.0
        self.timeField = t.1
        self.lastChargeField = popupRow(container, title: "\(localizedString("Last charge")):", value: "").1
        
        view.addSubview(separator)
        view.addSubview(container)
        
        return view
    }
    
    private func initBattery() -> NSView {
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.batteryHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        let separator = separatorView(localizedString("Battery"), origin: NSPoint(x: 0, y: self.batteryHeight-Constants.Popup.separatorHeight), width: self.frame.width)
        let container: NSStackView = NSStackView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: separator.frame.origin.y))
        container.orientation = .vertical
        container.spacing = 0
        
        self.healthField = popupRow(container, title: "\(localizedString("Health")):", value: "").1
        self.capacityField = popupRow(container, title: "\(localizedString("Capacity")):", value: "").1
        self.capacityField?.toolTip = localizedString("current / maximum / designed")
        self.cyclesField = popupRow(container, title: "\(localizedString("Cycles")):", value: "").1
        
        self.temperatureField = popupRow(container, title: "\(localizedString("Temperature")):", value: "").1
        self.batteryPowerField = popupRow(container, title: "\(localizedString("Power")):", value: "").1
        self.amperageField = popupRow(container, title: "\(localizedString("Current")):", value: "").1
        self.voltageField = popupRow(container, title: "\(localizedString("Voltage")):", value: "").1
        
        view.addSubview(separator)
        view.addSubview(container)
        
        return view
    }
    
    private func initAdapter() -> NSView {
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.adapterHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        let separator = separatorView(localizedString("Power adapter"), origin: NSPoint(x: 0, y: self.adapterHeight-Constants.Popup.separatorHeight), width: self.frame.width)
        let container: NSStackView = NSStackView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: separator.frame.origin.y))
        container.orientation = .vertical
        container.spacing = 0
        
        self.chargingStateField = popupRow(container, title: "\(localizedString("Is charging")):", value: "").1
        self.powerField = popupRow(container, title: "\(localizedString("Power")):", value: "").1
        self.chargingCurrentField = popupRow(container, title: "\(localizedString("Current")):", value: "").1
        self.chargingVoltageField = popupRow(container, title: "\(localizedString("Voltage")):", value: "").1
        
        self.adapterView = view
        
        view.addSubview(separator)
        view.addSubview(container)
        
        return view
    }
    
    private func initProcesses() -> NSView {
        if self.numberOfProcesses == 0 { return NSView() }
        
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.processesHeight))
        let separator = separatorView(localizedString("Top processes"), origin: NSPoint(x: 0, y: self.processesHeight-Constants.Popup.separatorHeight), width: self.frame.width)
        let container: ProcessesView = ProcessesView(
            frame: NSRect(x: 0, y: 0, width: self.frame.width, height: separator.frame.origin.y),
            values: [(localizedString("Usage"), nil)],
            n: self.numberOfProcesses
        )
        self.processes = container
        
        view.addSubview(separator)
        view.addSubview(container)
        
        self.processesView = view
        return view
    }
    
    private func labelValue(_ view: NSView, title: String, value: String) -> (NSTextField, NSTextField) {
        let rowView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: 22))
        
        let labelView: LabelField = LabelField(frame: NSRect(x: 0, y: (22-15)/2, width: view.frame.width/2, height: 15), title)
        let valueView: ValueField = ValueField(frame: NSRect(x: view.frame.width/2, y: (22-16)/2, width: view.frame.width/2, height: 16), value)
        
        rowView.addSubview(labelView)
        rowView.addSubview(valueView)
        
        if let view = view as? NSStackView {
            rowView.heightAnchor.constraint(equalToConstant: rowView.bounds.height).isActive = true
            view.addArrangedSubview(rowView)
        } else {
            view.addSubview(rowView)
        }
        
        return (labelView, valueView)
    }
    
    public func usageCallback(_ value: Battery_Usage) {
        DispatchQueue.main.async(execute: {
            self.dashboardBatteryView?.setValue(abs(value.level), lowPowerMode: value.lowPowerModeEnabled)
            
            self.levelField?.stringValue = "\(Int(abs(value.level) * 100))%"
            self.levelField?.toolTip = "\(value.currentCapacity) mAh"
            self.sourceField?.stringValue = localizedString(value.powerSource)
            self.timeField?.stringValue = ""
            
            if value.isBatteryPowered {
                self.timeLabelField?.stringValue = "\(localizedString("Time to discharge")):"
                if value.timeToEmpty != -1 && value.timeToEmpty != 0 {
                    self.timeField?.stringValue = Double(value.timeToEmpty*60).printSecondsToHoursMinutesSeconds(short: self.timeFormat == "short")
                } else {
                    self.timeField?.stringValue = localizedString("Unknown")
                }
                
                if self.adapterView != nil {
                    self.adapterView?.removeFromSuperview()
                    self.adapterView = nil
                    self.recalculateHeight()
                }
            } else {
                self.timeLabelField?.stringValue = "\(localizedString("Time to charge")):"
                if value.timeToCharge != -1 && value.timeToCharge != 0 {
                    self.timeField?.stringValue = Double(value.timeToCharge*60).printSecondsToHoursMinutesSeconds(short: self.timeFormat == "short")
                } else {
                    self.timeField?.stringValue = localizedString("Unknown")
                }
                
                if self.adapterView == nil {
                    self.insertArrangedSubview(self.initAdapter(), at: 3)
                    self.recalculateHeight()
                }
            }
            
            if value.timeToEmpty == -1 || value.timeToCharge == -1 {
                self.timeField?.stringValue = localizedString("Calculating")
            }
            
            if value.isCharged {
                self.timeField?.stringValue = localizedString("Fully charged")
            }
            
            self.healthField?.stringValue = "\(value.health)%"
            self.capacityField?.stringValue = "\(value.currentCapacity) / \(value.maxCapacity) / \(value.designedCapacity) mAh"
            
            if let state = value.state {
                self.healthField?.stringValue += " (\(state))"
            }
            self.cyclesField?.stringValue = "\(value.cycles)"
            
            let form = DateComponentsFormatter()
            form.maximumUnitCount = 2
            form.unitsStyle = .full
            form.allowedUnits = [.day, .hour, .minute]
            if let timestamp = value.timeOnACPower {
                if let duration = form.string(from: timestamp, to: Date()) {
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    formatter.dateStyle = .medium
                    
                    self.lastChargeField?.stringValue = duration
                    self.lastChargeField?.toolTip = formatter.string(from: timestamp)
                } else {
                    self.lastChargeField?.stringValue = localizedString("Unknown")
                    self.lastChargeField?.toolTip = localizedString("Unknown")
                }
            } else {
                self.lastChargeField?.stringValue = localizedString("Unknown")
                self.lastChargeField?.toolTip = localizedString("Unknown")
            }
            
            self.amperageField?.stringValue = "\(abs(value.amperage)) mA"
            self.voltageField?.stringValue = "\(value.voltage.roundTo(decimalPlaces: 2)) V"
            let batteryPower = value.voltage * (Double(abs(value.amperage))/1000)
            self.batteryPowerField?.stringValue = "\(batteryPower.roundTo(decimalPlaces: 2)) W"
            self.temperatureField?.stringValue = temperature(value.temperature)
            
            self.powerField?.stringValue = value.isBatteryPowered ? localizedString("Not connected") : "\(value.ACwatts) W"
            self.chargingStateField?.stringValue = value.isCharging ? localizedString("Yes") : localizedString("No")
            self.chargingCurrentField?.stringValue = value.isBatteryPowered ? localizedString("Not connected") : "\(value.chargingCurrent) mA"
            self.chargingVoltageField?.stringValue = value.isBatteryPowered ? localizedString("Not connected") : "\(value.chargingVoltage) mV"
        })
    }
    
    public func processCallback(_ list: [TopProcess]) {
        DispatchQueue.main.async(execute: {
            if !(self.window?.isVisible ?? false) && self.processesInitialized {
                return
            }
            let list = list.map { $0 }
            if list.count != self.processes?.count { self.processes?.clear() }
            
            for i in 0..<list.count {
                let process = list[i]
                self.processes?.set(i, process, ["\(process.usage)%"])
            }
            
            self.processesInitialized = true
        })
    }
    
    public func numberOfProcessesUpdated() {
        if self.processes?.count == self.numberOfProcesses { return }
        
        DispatchQueue.main.async(execute: {
            self.processesView?.removeFromSuperview()
            self.processesView = nil
            self.processes = nil
            self.addArrangedSubview(self.initProcesses())
            self.processesInitialized = false
            self.recalculateHeight()
        })
    }
    
    // MARK: - Settings
    
    public override func settings() -> NSView? {
        let view = SettingsContainerView()
        
        view.addArrangedSubview(PreferencesSection([
            PreferencesRow(localizedString("Keyboard shortcut"), component: KeyboardShartcutView(
                callback: self.setKeyboardShortcut,
                value: self.keyboardShortcut
            ))
        ]))
        
        view.addArrangedSubview(PreferencesSection([
            PreferencesRow(localizedString("Colorize battery"), component: switchView(
                action: #selector(self.toggleColor),
                state: self.colorState
            ))
        ]))
        
        return view
    }
    
    @objc private func toggleColor(_ sender: NSControl) {
        self.colorState = controlState(sender)
        Store.shared.set(key: "\(self.title)_color", value: self.colorState)
        self.dashboardBatteryView?.display()
    }
}

internal class BatteryView: NSView {
    private var percentage: Double = 0
    private var lowPowerMode: Bool = false
    
    private var colorState: Bool {
        return Store.shared.bool(key: "Battery_color", defaultValue: false)
    }
    
    public override init(frame: NSRect = NSRect.zero) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let w: CGFloat = min(self.frame.width, 120)
        let h: CGFloat = min(self.frame.height, 50)
        let x: CGFloat = (self.frame.width - w)/2
        let y: CGFloat = (self.frame.size.height - h) / 2
        let batteryFrame = NSBezierPath(roundedRect: NSRect(x: x+1, y: y+1, width: w-8, height: h-2), xRadius: 3, yRadius: 3)
        
        NSColor.textColor.set()
        
        let bPX: CGFloat = batteryFrame.bounds.origin.x + batteryFrame.bounds.width
        let bPY: CGFloat = batteryFrame.bounds.origin.y + (batteryFrame.bounds.height/2) - 4
        let batteryPoint = NSBezierPath(roundedRect: NSRect(x: bPX-2, y: bPY, width: 8, height: 8), xRadius: 4, yRadius: 4)
        batteryPoint.fill()
        
        let batteryPointSeparator = NSBezierPath()
        batteryPointSeparator.move(to: CGPoint(x: bPX, y: batteryFrame.bounds.origin.y))
        batteryPointSeparator.line(to: CGPoint(x: bPX, y: batteryFrame.bounds.origin.y + batteryFrame.bounds.height))
        ctx.saveGState()
        ctx.setBlendMode(.destinationOut)
        NSColor.textColor.set()
        batteryPointSeparator.lineWidth = 4
        batteryPointSeparator.stroke()
        ctx.restoreGState()
        
        batteryFrame.lineWidth = 1
        batteryFrame.stroke()
        
        let inner = NSBezierPath(roundedRect: NSRect(
            x: x+2,
            y: y+2,
            width: (w-10) * CGFloat(self.percentage),
            height: h-4
        ), xRadius: 3, yRadius: 3)
        self.percentage.batteryColor(color: self.colorState, lowPowerMode: self.lowPowerMode).set()
        inner.lineWidth = 0
        inner.stroke()
        inner.close()
        inner.fill()
    }
    
    public func setValue(_ value: Double, lowPowerMode: Bool = false) {
        if self.percentage == value && self.lowPowerMode == lowPowerMode {
            return
        }
        
        self.percentage = value
        self.lowPowerMode = lowPowerMode
        DispatchQueue.main.async(execute: {
            self.display()
        })
    }
}

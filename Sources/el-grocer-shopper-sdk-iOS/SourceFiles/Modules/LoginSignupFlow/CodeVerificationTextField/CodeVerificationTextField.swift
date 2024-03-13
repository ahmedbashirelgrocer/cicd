//
//  CodeVerificationTextField.swift
//  CodeVerificationTextField
//
//  Created by Sarmad Abbas on 20/09/2022.
//
//

import UIKit

public class CodeVerificationTextField: UITextField {
    
    // MARK: - Control properties
    
    public var isError = false {
        didSet {
            if isError == true {
                textLabels.forEach{ $0.layer.borderColor = #colorLiteral(red: 0.5909515023, green: 0.05450856686, blue: 0.00671703741, alpha: 1) }
            } else {
                textLabels.forEach{ $0.layer.borderColor = UIColor.clear.cgColor }
            }
        }
    }
    public var numberOfTextFields: Int = 4 { didSet { addTextLabelsToStackView() } }
    public override var backgroundColor: UIColor? {
        set { textLabels.forEach{ $0.backgroundColor = newValue } }
        get { textLabels.first?.backgroundColor }
    }
    
    // MARK: - Private properties
    
    private var stackView: UIStackView
    private var textLabels: [BorderedLabel] = []
    
    // MARK: Initialization
    
    init(cellSpacing: CGFloat) {
        stackView = CodeVerificationTextField.makeStackView(spacing: cellSpacing)
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        stackView = CodeVerificationTextField.makeStackView(spacing: 12)
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        initialSetup()
        addTargets()
        addStackView()
        // addTextLabelsToStackView()
    }
    
    @objc func textChanged() {
        guard let txt = self.text, txt.count <= numberOfTextFields else {
            text = String(self.text?.prefix(4) ?? "")
            return
        }
        
        for index in 0..<textLabels.count {
            textLabels[index].highlight = false
            if txt.count > index { textLabels[index].text = txt.stringAt(id: index) }
            else { textLabels[index].text = nil }
        }
        
        highlightNext()
    }
    
    // MARK: Responder handling
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        if isError {
            isError = false
            clearText()
        }
        highlightNext()
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textLabels.forEach { $0.highlight = false }
        return super.resignFirstResponder()
    }
    
    // MARK: Public functions
    
    public func clearText() {
        text = nil
        textLabels.forEach { $0.text = nil }
    }
}

// MARK: Drawing
extension CodeVerificationTextField {
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    public override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
}

// MARK: View setup
fileprivate extension CodeVerificationTextField {
    
    func addStackView() {
        // Add stack view
        addSubview(stackView)
        
        // Add stack view constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
        ])
    }
    
    func addTextLabelsToStackView() {
        // Clear Previously added labels first
        textLabels.removeAll()
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        
        // Add labels to stackView and a reference
        for _ in 0..<numberOfTextFields {
            let borderedTextLabel = makeBorderedLabel()
            stackView.addArrangedSubview(borderedTextLabel)
            textLabels.append(borderedTextLabel)
        }
        
        // SetupConstraints
        for index in 0..<numberOfTextFields {
            let constraint = textLabels[index].widthAnchor.constraint(equalTo: textLabels[index].heightAnchor)
            constraint.priority = UILayoutPriority(750)
            constraint.isActive = true
            textLabels[index].heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
    }
}

fileprivate extension CodeVerificationTextField {
    
    // Factary Methods
    static func makeStackView(spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.semanticContentAttribute = .forceLeftToRight
        return stackView
    }
    
    func makeBorderedLabel() -> BorderedLabel {
        return BorderedLabel()
    }
    
    // Helpers
    
    func initialSetup() {
        borderStyle = .none
        keyboardType = .phonePad
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 12, *) { textContentType = .oneTimeCode }
    }
    
    func addTargets() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder)))
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    func highlightNext() {
        let count = text?.count ?? 0
        let index = count < numberOfTextFields ? count : numberOfTextFields - 1
        textLabels[index].highlight = true
    }
}

// MARK: BorderedLabel

public class BorderedLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public var highlightedBorderColor: UIColor = #colorLiteral(red: 0.02752153389, green: 0.7365019917, blue: 0.4025406539, alpha: 1)
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 22)
        textAlignment = .center
        textColor = #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.878000021, blue: 0.9409999847, alpha: 1).withAlphaComponent(0.36)
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    public var highlight: Bool = false {
        didSet {
            layer.borderColor = highlight ? highlightedBorderColor.cgColor: UIColor.clear.cgColor
        }
    }
}

fileprivate extension String {
    func stringAt(id: Int) -> String {
        return String(self[index(startIndex, offsetBy: id)])
    }
}

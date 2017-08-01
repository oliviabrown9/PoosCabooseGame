//
//  Lippi
//  MessageComposer.swift
//
//  obrown917@gmail.com
//  Copyright © 2016 Olivia Brown. All rights reserved.
//

import Foundation
import MessageUI

var sent = false

let textMessageRecipients = ["\(selectedPhoneNumber)"]

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // Checks if a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = "Download this app."
        return messageComposeVC
    }
    // Dismisses the view controller when the user is finished with it
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            controller.dismiss(animated: true, completion: nil)
            
        default:
            break;
        }
    }
}

//
//  NetworkManagerExeptions.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import Foundation

enum NetworkManagerExeptions: Error {
    case URLInvalid;
    case HTTPResponseError;
    case JSONDecoderError;
    case JSONEncoderError;
    case Generic;
}

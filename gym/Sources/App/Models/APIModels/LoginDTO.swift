import Foundation
import Vapor

struct LoginDTO: Content {

    let email: String
    let password: String
}

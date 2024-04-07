import Foundation
import Fluent
import Vapor

final class Membership: Model, Content {

    static var schema = "memberships"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "weekly_price")
    var weeklyPrice: Float

    @Field(key: "monthly_price")
    var monthlyPrice: Float

    @Field(key: "yearly_price")
    var yearlyPrice: Float

    init() {}

    init(
        id: UUID? = nil,
        title: String,
        description: String,
        weeklyPrice: Float,
        monthlyPrice: Float,
        yearlyPrice: Float
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.weeklyPrice = weeklyPrice
        self.monthlyPrice = monthlyPrice
        self.yearlyPrice = yearlyPrice
    }
}

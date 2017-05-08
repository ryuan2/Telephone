//
//  ContactMatchingIndexTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import UseCases
import UseCasesTestDoubles
import XCTest

final class ContactMatchingIndexTests: XCTestCase {
    func testFindsContactsByPhoneNumberAndEmailAddress() {
        let contact1 = makeContact(number: 1)
        let contact2 = makeContact(number: 2)

        let sut = ContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: 20)

        XCTAssertEqual(sut.contact(forAddress: contact1.phones[0].number), makeMatchedContact(contact: contact1, phoneIndex: 0))
        XCTAssertEqual(sut.contact(forAddress: contact1.phones[1].number), makeMatchedContact(contact: contact1, phoneIndex: 1))
        XCTAssertEqual(sut.contact(forAddress: contact1.emails[0].address), makeMatchedContact(contact: contact1, emailIndex: 0))
        XCTAssertEqual(sut.contact(forAddress: contact1.emails[1].address), makeMatchedContact(contact: contact1, emailIndex: 1))
        XCTAssertEqual(sut.contact(forAddress: contact2.phones[0].number), makeMatchedContact(contact: contact2, phoneIndex: 0))
        XCTAssertEqual(sut.contact(forAddress: contact2.phones[1].number), makeMatchedContact(contact: contact2, phoneIndex: 1))
        XCTAssertEqual(sut.contact(forAddress: contact2.emails[0].address), makeMatchedContact(contact: contact2, emailIndex: 0))
        XCTAssertEqual(sut.contact(forAddress: contact2.emails[1].address), makeMatchedContact(contact: contact2, emailIndex: 1))
    }

    func testFindsContactsByLastDigitsOfPhoneNumber() {
        let contact1 = makeContact(number: 1)
        let contact2 = makeContact(number: 2)
        let length = 7

        let sut = ContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: length)

        XCTAssertEqual(sut.contact(forAddress: lastDigits(of: contact1.phones[0].number, length: length)), makeMatchedContact(contact: contact1, phoneIndex:0))
        XCTAssertEqual(sut.contact(forAddress: lastDigits(of: contact1.phones[1].number, length: length)), makeMatchedContact(contact: contact1, phoneIndex:1))
        XCTAssertEqual(sut.contact(forAddress: lastDigits(of: contact2.phones[0].number, length: length)), makeMatchedContact(contact: contact2, phoneIndex:0))
        XCTAssertEqual(sut.contact(forAddress: lastDigits(of: contact2.phones[1].number, length: length)), makeMatchedContact(contact: contact2, phoneIndex:1))
    }
}

private func makeContact(number: Int) -> Contact {
    return Contact(name: "name-\(number)", phones: makePhones(number: number), emails: makeEmails(number: number))
}

private func makePhones(number: Int) -> [Contact.Phone] {
    return [
        Contact.Phone(number: "1234567891\(number)", label: "label-\(number)"),
        Contact.Phone(number: "9876543212\(number)", label: "label-\(number)")
    ]
}

private func makeEmails(number: Int) -> [Contact.Email] {
    return [
        Contact.Email(address: "foo\(number)@host", label: "label-\(number)"),
        Contact.Email(address: "bar\(number)@host", label: "label-\(number)")
    ]
}

private func makeMatchedContact(contact: Contact, phoneIndex index: Int) -> MatchedContact {
    let phone = contact.phones[index]
    return MatchedContact(name: contact.name, address: .phone(number: phone.number, label: phone.label))
}

private func makeMatchedContact(contact: Contact, emailIndex index: Int) -> MatchedContact {
    let email = contact.emails[index]
    return MatchedContact(name: contact.name, address: .email(address: email.address, label: email.label))
}

private func lastDigits(of string: String, length: Int) -> String {
    let result = NormalizedPhoneNumber(string, maxLength: length).value
    assert(result.characters.count == length)
    return result
}
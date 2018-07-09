import TeapotMac
import XCTest

class LoggerTests: XCTestCase {
    private lazy var logger = Logger()

    func testDefaultConstructorPrintsNothing() {
        XCTAssertFalse(self.logger.errorLog("Did this error log print?"))
        XCTAssertFalse(self.logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(self.logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testNonePrintsNothing() {
        self.logger.currentLevel = .none

        XCTAssertFalse(self.logger.errorLog("Did this error log print?"))
        XCTAssertFalse(self.logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(self.logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testErrorOnlyPrintsErrors() {
        self.logger.currentLevel = .error

        XCTAssertTrue(self.logger.errorLog("Did this error log print?"))
        XCTAssertFalse(self.logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(self.logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testIncomingPrintsIncomingAndErrors() {
        self.logger.currentLevel = .incomingData

        XCTAssertTrue(self.logger.errorLog("Did this error log print?"))
        XCTAssertTrue(self.logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(self.logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testIncomingOutgoingPrintsEverything() {
        self.logger.currentLevel = .incomingAndOutgoingData

        XCTAssertTrue(self.logger.errorLog("Did this error log print?"))
        XCTAssertTrue(self.logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertTrue(self.logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }
}

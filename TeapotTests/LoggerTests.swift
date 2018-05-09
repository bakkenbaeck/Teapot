import XCTest
import TeapotMac

class LoggerTests: XCTestCase {

    private lazy var logger = Logger()

    func testDefaultConstructorPrintsNothing() {

        XCTAssertFalse(logger.errorLog("Did this error log print?"))
        XCTAssertFalse(logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testNonePrintsNothing() {
        logger.currentLevel = .none

        XCTAssertFalse(logger.errorLog("Did this error log print?"))
        XCTAssertFalse(logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testErrorOnlyPrintsErrors() {
        logger.currentLevel = .error

        XCTAssertTrue(logger.errorLog("Did this error log print?"))
        XCTAssertFalse(logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }

    func testIncomingPrintsIncomingAndErrors() {
        logger.currentLevel = .incomingData

        XCTAssertTrue(logger.errorLog("Did this error log print?"))
        XCTAssertTrue(logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertFalse(logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))

    }

    func testIncomingOutgoingPrintsEverything() {
        logger.currentLevel = .incomingAndOutgoingData

        XCTAssertTrue(logger.errorLog("Did this error log print?"))
        XCTAssertTrue(logger.incomingDataLog("Did this incoming only log print?"))
        XCTAssertTrue(logger.incomingAndOutgoingDataLog("Did this incoming and outgoing log print?"))
    }
}

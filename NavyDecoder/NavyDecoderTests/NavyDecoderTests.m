//
// NavyDecoderTests.m
// NavyDecoderTests
//
// This file is part of Navy Decoder-iOS.
//
// Navy Decoder-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Navy Decoder-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Navy Decoder-iOS.  If not, see <https://www.gnu.org/licenses/>.
//
// Copyright (c) 2014-2025 Crash Test Dummy Limited, LLC
//

#import "NavyDecoderTests.h"
#import "NDDataStore.h"
#import "NDDecoderItem.h"

@implementation NavyDecoderTests

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

- (NDDecoderItem *)itemWithKey:(NSString *)key inCategory:(NSString *)category {
    NSArray<NDDecoderItem *> *items = [[NDDataStore sharedStore] itemsForCategoryTitle:category];
    for (NDDecoderItem *item in items) {
        if ([item.codeKey isEqualToString:key]) {
            return item;
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------
// Category list sanity
// ---------------------------------------------------------------------------

- (void)testCategoryCount {
    // The JSON currently defines 16 distinct categoryTitle values.
    NSArray<NSString *> *titles = [[NDDataStore sharedStore] categoryTitles];
    XCTAssertEqual(titles.count, 16u, @"Expected 16 categories; check for missing or duplicate tables in the SQL-to-JSON conversion.");
}

// ---------------------------------------------------------------------------
// Per-category decode tests
// Each test verifies:
//   1. The category has at least one item.
//   2. A known key resolves to the expected codeValue.
// ---------------------------------------------------------------------------

- (void)testDecode_AQD {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"AQD"];
    XCTAssertGreaterThan(items.count, 0u, @"AQD category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"AA2" inCategory:@"AQD"];
    XCTAssertNotNil(item, @"AQD key 'AA2' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Program Management-Level 2 Functional Area Certified");
}

- (void)testDecode_EnlistedRating {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"Enlisted Rating"];
    XCTAssertGreaterThan(items.count, 0u, @"Enlisted Rating category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"AN" inCategory:@"Enlisted Rating"];
    XCTAssertNotNil(item, @"Enlisted Rating key 'AN' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Airman");
}

- (void)testDecode_IMS {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"IMS"];
    XCTAssertGreaterThan(items.count, 0u, @"IMS category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"RXX" inCategory:@"IMS"];
    XCTAssertNotNil(item, @"IMS key 'RXX' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Precedes R##. HQ use only for planning purposes.");
}

- (void)testDecode_MAS {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"MAS"];
    XCTAssertGreaterThan(items.count, 0u, @"MAS category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"MS1" inCategory:@"MAS"];
    XCTAssertNotNil(item, @"MAS key 'MS1' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Line of Duty Initiated");
}

- (void)testDecode_NEC {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"NEC"];
    XCTAssertGreaterThan(items.count, 0u, @"NEC category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"0091" inCategory:@"NEC"];
    XCTAssertNotNil(item, @"NEC key '0091' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Fit for Continued Naval Service but Not Worldwide Assignable");
}

- (void)testDecode_NOBC {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"NOBC"];
    XCTAssertGreaterThan(items.count, 0u, @"NOBC category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"0000" inCategory:@"NOBC"];
    XCTAssertNotNil(item, @"NOBC key '0000' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Transient, Patients, Prisoners, And Holdees");
}

- (void)testDecode_NRA {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"NRA"];
    XCTAssertGreaterThan(items.count, 0u, @"NRA category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"0600" inCategory:@"NRA"];
    XCTAssertNotNil(item, @"NRA key '0600' not found.");
    XCTAssertEqualObjects(item.codeValue, @"REDCOM MA NORFOLK, VA");
}

- (void)testDecode_OfficerBillet {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"Officer Billet"];
    XCTAssertGreaterThan(items.count, 0u, @"Officer Billet category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"1000" inCategory:@"Officer Billet"];
    XCTAssertNotNil(item, @"Officer Billet key '1000' not found.");
    XCTAssertEqualObjects(item.codeValue,
                          @"Billet which may be filled by any appropriately skilled and experienced Unrestricted Line Officer or Special Duty Officer");
}

- (void)testDecode_OfficerDesignator {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"Officer Designator"];
    XCTAssertGreaterThan(items.count, 0u, @"Officer Designator category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"110X" inCategory:@"Officer Designator"];
    XCTAssertNotNil(item, @"Officer Designator key '110X' not found.");
    XCTAssertEqualObjects(item.codeValue,
                          @"An Unrestricted Line Officer who is not qualified in any warfare specialty or in training for any warfare specialty");
}

- (void)testDecode_OfficerPaygrade {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"Officer Paygrade"];
    XCTAssertGreaterThan(items.count, 0u, @"Officer Paygrade category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"A" inCategory:@"Officer Paygrade"];
    XCTAssertNotNil(item, @"Officer Paygrade key 'A' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Fleet Admiral (011 FADM)");
}

- (void)testDecode_RBSC {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"RBSC"];
    XCTAssertGreaterThan(items.count, 0u, @"RBSC category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"A" inCategory:@"RBSC"];
    XCTAssertNotNil(item, @"RBSC key 'A' not found.");
    XCTAssertEqualObjects(item.codeValue, @"Billet advertising in APPLY, JOAPPLY or CMS-ID");
}

- (void)testDecode_RPC {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"RPC"];
    XCTAssertGreaterThan(items.count, 0u, @"RPC category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"00" inCategory:@"RPC"];
    XCTAssertNotNil(item, @"RPC key '00' not found.");
    XCTAssertEqualObjects(item.codeValue, @"RESERVE");
}

- (void)testDecode_RUIC {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"RUIC"];
    XCTAssertGreaterThan(items.count, 0u, @"RUIC category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"81978" inCategory:@"RUIC"];
    XCTAssertNotNil(item, @"RUIC key '81978' not found.");
    XCTAssertEqualObjects(item.codeValue, @"NR ADDU (CNRFC HQ)");
}

- (void)testDecode_SSP {
    NSArray *items = [[NDDataStore sharedStore] itemsForCategoryTitle:@"SSP"];
    XCTAssertGreaterThan(items.count, 0u, @"SSP category is empty.");
    NDDecoderItem *item = [self itemWithKey:@"2000" inCategory:@"SSP"];
    XCTAssertNotNil(item, @"SSP key '2000' not found.");
    XCTAssertEqualObjects(item.codeValue, @"National Security Studies");
}

// RFAS categories are placeholder rows whose codes are handled by Rfas.m,
// not decoded from the JSON.  Just confirm they appear in categoryTitles.
- (void)testCategoryTitles_ContainsRFASEnlisted {
    NSArray<NSString *> *titles = [[NDDataStore sharedStore] categoryTitles];
    XCTAssertTrue([titles containsObject:@"RFAS-Enlisted"], @"RFAS-Enlisted missing from categoryTitles.");
}

- (void)testCategoryTitles_ContainsRFASOfficer {
    NSArray<NSString *> *titles = [[NDDataStore sharedStore] categoryTitles];
    XCTAssertTrue([titles containsObject:@"RFAS-Officer"], @"RFAS-Officer missing from categoryTitles.");
}

// ---------------------------------------------------------------------------
// Cross-category search smoke test
// ---------------------------------------------------------------------------

- (void)testSearch_ReturnsResultsForKnownTerm {
    NSArray<NDDecoderItem *> *results = [[NDDataStore sharedStore] searchAllItemsForText:@"Airman"];
    XCTAssertGreaterThan(results.count, 0u, @"Search for 'Airman' returned no results.");
}

- (void)testSearch_ReturnsEmptyForBlankQuery {
    NSArray<NDDecoderItem *> *results = [[NDDataStore sharedStore] searchAllItemsForText:@""];
    XCTAssertEqual(results.count, 0u, @"Search with empty string should return no results.");
}

@end

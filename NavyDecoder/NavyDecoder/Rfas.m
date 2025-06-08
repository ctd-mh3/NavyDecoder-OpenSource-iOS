//
// Rfas.m
// NavyDecoder-iOS
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

#import "Rfas.h"

@interface Rfas ()

@property (strong, nonatomic) NSArray *officerFirstCharacterMatrix;
@property (strong, nonatomic) NSArray *officerSecondAndThirdCharactersMatrix;
@property (strong, nonatomic) NSArray *fourthCharacterMatrix;
@property (strong, nonatomic) NSArray *enlistedFirstCharacterMatrix;
@property (strong, nonatomic) NSArray *enlistedSecondAndThirdCharactersMatrix;

@end

@implementation Rfas

@synthesize officerFirstCharacterMatrix = _officerFirstCharacterMatrix;
@synthesize officerSecondAndThirdCharactersMatrix = _officerSecondAndThirdCharactersMatrix;
@synthesize fourthCharacterMatrix = _fourhCharacterMatrix;
@synthesize enlistedFirstCharacterMatrix = _enlistedFirstCharacterMatrix;
@synthesize enlistedSecondAndThirdCharactersMatrix = _enlistedSecondAndThirdCharactersMatrix;

- (id)init {
    self = [super init];
   
    if (self) {
         self.officerFirstCharacterMatrix = [NSArray arrayWithObjects:
//                [NSArray arrayWithObjects:@"1", @"Exact Paygrade Match Only (see Officer Paygrade Code)", nil],
                [NSArray arrayWithObjects:@"S", @"O6-W1 (Exact paygrade match only)", nil],
                [NSArray arrayWithObjects:@"M", @"O6-O3 (Medical designators only)", nil],
                [NSArray arrayWithObjects:@"I", @"O4-O1", nil],
                [NSArray arrayWithObjects:@"K", @"O3-O1", nil],
                [NSArray arrayWithObjects:@"P", @"O4-O3", nil],
                [NSArray arrayWithObjects:@"X", @"O4-W1", nil],
                [NSArray arrayWithObjects:@"W", @"W5-W1", nil],
                nil];

        self.officerSecondAndThirdCharactersMatrix = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"AA", @"Must match designator and any coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"AB", @"Must match designator. If AQD and/or SSP coded, member must earn AQD and/or SSP within three years.", nil],
                [NSArray arrayWithObjects:@"AC", @"Must match designator", nil],
                [NSArray arrayWithObjects:@"AJ", @"1XXX", nil],
                [NSArray arrayWithObjects:@"AK", @"1XXX and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"AL", @"1XXX, 6XXX, 7XXX", nil],
                [NSArray arrayWithObjects:@"AM", @"1XXX, 6XXX, 7XXX and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"AQ", @"1050, 11XX, 13XX", nil],
                [NSArray arrayWithObjects:@"AR", @"11XX, 13XX and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"EB", @"112X, 62XX, 713X", nil],
                [NSArray arrayWithObjects:@"ED", @"110X, 111X, 112X, 62XX, 72XX", nil],
                [NSArray arrayWithObjects:@"EF", @"110X, 111X, 112X, 62XX, 72XX and any coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"FE", @"131X, 132X", nil],
                [NSArray arrayWithObjects:@"FF", @"131X, 132X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"FK", @"130X, 131X, 132X", nil],
                [NSArray arrayWithObjects:@"FL", @"130X, 131X, 132X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"GU", @"110X, 111X, 112X, 144X, 613X, 614X, 618X, 623X, 626X, 713X", nil],
                [NSArray arrayWithObjects:@"HB", @"13XX, 150X, 151X, 152X, 633X, 733X; With requisite Engineering System Development (for 151X billet) or Aviation Maintenance (for 152X billet) background/experience.", nil],
                [NSArray arrayWithObjects:@"JS", @"200X, 210X, 220X, 230X, 270X, 290X", nil],
                [NSArray arrayWithObjects:@"JQ", @"200X, 210X, 220X, 230X, 270X, 290X and must match any coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"KP", @"310X, 651X, 751X", nil],
                [NSArray arrayWithObjects:@"KQ", @"310X, 651X, 751X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"LB", @"510X, 653X, 753X", nil],
                [NSArray arrayWithObjects:@"LC", @"510X, 653X, 753X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"LW", @"6XXX, 7XXX within skill categories (2nd and 3rd digit of designator match, i.e. 611X can fill 711X billet or vice versa; 633X and 734X are considered equivalent skill categories).", nil],
                [NSArray arrayWithObjects:@"LX", @"6XXX, 7XXX within skill categories (2nd and 3rd digit of designator match, i.e. 611X can fill 711X billet or vice versa; 633x and 734X are considered equivalent skill categories) and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"MO", @"11XX, 166X", nil],
                [NSArray arrayWithObjects:@"MP", @"111X, 166X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"OM", @"181X, 781X", nil],
                [NSArray arrayWithObjects:@"ON", @"183X, 683X, 783X", nil],
                [NSArray arrayWithObjects:@"OP", @"182X, 682X, 782X", nil],
                [NSArray arrayWithObjects:@"OQ", @"181X, 781X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"OR", @"18XX, 682X, 683X, 781X, 782X, 783X or any designator holding a VSX AQD", nil],
                [NSArray arrayWithObjects:@"OS", @"Any designator. Must hold a VSX AQD (Space Cadre)", nil],
                [NSArray arrayWithObjects:@"OT", @"183X, 683X, 783X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"OU", @"182X, 682X, 782X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"OY", @"Any designator. Must hold VSX AQD at or higher than the billet AQD requirement, or the member must sign a NAVPERS 1070/613 and earn the required AQD within three years.", nil],
                [NSArray arrayWithObjects:@"OZ", @"Any designator. Must hold a VSX AQD at or higher than the billet AQD requirement.", nil],
                [NSArray arrayWithObjects:@"SO", @"113X, 114X", nil],
                [NSArray arrayWithObjects:@"SP", @"113X, 114X and coded SSP or AQD", nil],
                [NSArray arrayWithObjects:@"SU", @"1XXX, Staff Corps (NEPLO Only)", nil],
                [NSArray arrayWithObjects:@"SV", @"1XXX, Staff Corps (NEPLO Only). Must hold JN1 AQD", nil],
                nil];

        self.enlistedFirstCharacterMatrix = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"M", @"Command Master Chief Billet", nil],
                [NSArray arrayWithObjects:@"9", @"E9 - (E8 and E9 (E9 Authorized Rating))", nil],
                [NSArray arrayWithObjects:@"S", @"Command Senior Chief Billet (E8 Only)", nil],
                [NSArray arrayWithObjects:@"8", @"E8 - (E7 through E9 (E8 Authorized Rating))", nil],
                [NSArray arrayWithObjects:@"7", @"E7 - (E7 and E8 (E7 Authorized Rating))", nil],
                [NSArray arrayWithObjects:@"6", @"E6 - (E5 and E6 (E6 Authorized Rating))", nil],
                [NSArray arrayWithObjects:@"Z", @"E5 through E8 requiring NEC (CNAFR Only)", nil],
                [NSArray arrayWithObjects:@"J", @"E5 and E6 - (E5 or E6 Authorized Rating)", nil],
                [NSArray arrayWithObjects:@"5", @"E5 - (E4 through E6 (E5 Authorized Rating))", nil],
                [NSArray arrayWithObjects:@"4", @"E1 through E5 - (E4 Authorized Rating)", nil],
                [NSArray arrayWithObjects:@"3", @"E1 through E3 - (E1, E2, E3, E4 Authorized Rating)", nil],
                [NSArray arrayWithObjects:@"N", @"E1 through E6 meeting horizontal AB or BB RFAS", nil],
                nil];

        self.enlistedSecondAndThirdCharactersMatrix = [NSArray arrayWithObjects:
             [NSArray arrayWithObjects:@"AA", @"Must match billet rating", nil],
             [NSArray arrayWithObjects:@"AB", @"Any source rate of the required NEC earned within time period designated by program manager", nil],
             [NSArray arrayWithObjects:@"AC", @"BM, OS, QM", nil],
             [NSArray arrayWithObjects:@"AD", @"EM, GSE", nil],
             [NSArray arrayWithObjects:@"AE", @"EN, GSM, MM, MMA, MMW, TM", nil],
             [NSArray arrayWithObjects:@"AF", @"DC, HT, MR", nil],
             [NSArray arrayWithObjects:@"AG", @"AD, AE, AF, AM, AME, AO, AT, AV, AZ, PR", nil],
             [NSArray arrayWithObjects:@"AI", @"AB, ABF, ABH, AC, AG", nil],
             [NSArray arrayWithObjects:@"AH", @"AB, ABH, ABF", nil],
             [NSArray arrayWithObjects:@"AJ", @"ET, ETR, ETV, FC, FT, STG, STS", nil],
             [NSArray arrayWithObjects:@"AM", @"ET, ETV, ETR, IT, ITS", nil],
             [NSArray arrayWithObjects:@"AN", @"Any Airman rating except AB (All), AC, AG, AW (All)", nil],
             [NSArray arrayWithObjects:@"AP", @"Any Constructionman rating", nil],
             [NSArray arrayWithObjects:@"AR", @"LN, MC, PS, RP, YN, YNS", nil],
             [NSArray arrayWithObjects:@"AS", @"CS, CSS, LS, LSS, RS", nil],
             [NSArray arrayWithObjects:@"AT", @"EOD, ND, SB, SO", nil],
             [NSArray arrayWithObjects:@"AU", @"GM, MN", nil],
             [NSArray arrayWithObjects:@"AV", @"EOD holding NEC 5337, ET, ETR, ETV, FC, MN, OS, STG, STS", nil],
             [NSArray arrayWithObjects:@"AZ", @"Any AW rating", nil],
             [NSArray arrayWithObjects:@"BB", @"Any source rating of the required NEC and must hold the NEC or component NEC per NAVPERS 18068F, Chapter IV", nil],
             [NSArray arrayWithObjects:@"BD", @"ET, ETR, ETV, FC, FT, IT, ITS", nil],
             [NSArray arrayWithObjects:@"CC", @"Must match rate and NEC per NAVPERS 18068F", nil],
             [NSArray arrayWithObjects:@"CD", @"AG, CTI, CTR, CTT, CWT (Legacy CTN), IS, IT, ITS", nil],
             [NSArray arrayWithObjects:@"CN", @"CTI, CTR, CTT, CWT (Legacy CTN)", nil],
             [NSArray arrayWithObjects:@"CS", @"ET, ETR, ETV, FC, FT, IT, ITS, MT, OS, QM, STG, STS", nil],
             [NSArray arrayWithObjects:@"DM", @"AD, AF, AM", nil],
             [NSArray arrayWithObjects:@"AE", @"AE, AT, AV", nil],
             [NSArray arrayWithObjects:@"FN", @"Any Fireman rating", nil],
             [NSArray arrayWithObjects:@"GS", @"MA or any rate holding 815A NEC (9545 Legacy NEC)", nil],
             [NSArray arrayWithObjects:@"SF", @"BM, DC, EM, EN, ET, ETV, ETR, FC, GM, GSE, GSM, HT, IC, MN, MM, MMA, MMW, MR, OS, QM, STG, STS, TM", nil],
             [NSArray arrayWithObjects:@"SN", @"Any Seaman Rating", nil],
                nil];

        self.fourthCharacterMatrix = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"E", @"Either Gender", nil],
                [NSArray arrayWithObjects:@"R", @"Billet is eligible for IDT-R", nil],
                nil];
        
    
    }
    
    return self;
}

- (NSArray *)getArrayForCharacterGroup:(int)character isEnlisted:(BOOL)isEnlisted {
    NSArray *arrayToReturn;
    
    switch (character) {
        case 1:
            if (isEnlisted) {
                arrayToReturn = self.enlistedFirstCharacterMatrix;
            } else {
                arrayToReturn = self.officerFirstCharacterMatrix;
            }
            break;
        case 2:
            if (isEnlisted) {
                arrayToReturn = self.enlistedSecondAndThirdCharactersMatrix;
            } else {
                arrayToReturn = self.officerSecondAndThirdCharactersMatrix;
            }
            break;
        case 3:
            arrayToReturn = self.fourthCharacterMatrix;
            break;
        default:
            break;
    }
    
    return arrayToReturn;
}

- (NSArray *)getFirstCharacterKeys:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:1
                                              isEnlisted:isEnlisted];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];;
    
    for (id subArray in tempArray) {
//        NSString *tempString = [subArray description];
//        NSString *tempString2 = [subArray objectAtIndex:0];
//        NSString *tempString3 = [subArray objectAtIndex:1];
        
        [keyArray addObject:[subArray objectAtIndex:0]];
//        [keyArray addObject:tempString2];
    }    
//    NSArray *temp2Array = [tempArray objectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
    return keyArray;
}

- (NSArray *)getSecondAndThirdCharactersKeys:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:2
                                              isEnlisted:isEnlisted];
   
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];;
    
    for (id subArray in tempArray) {
        [keyArray addObject:[subArray objectAtIndex:0]];
    }

    return keyArray;
}

- (NSArray *)getFourthCharacterKeys:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:3
                                              isEnlisted:isEnlisted];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];;
    
    for (id subArray in tempArray) {
        [keyArray addObject:[subArray objectAtIndex:0]];
    }
    
    return keyArray;
}

- (NSString *)getFirstCharacterKeyForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:1
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:0];
}

- (NSString *)getSecondAndThirdCharactersKeyForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:2
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:0];
}

- (NSString *)getFourthCharacterKeyForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:3
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:0];
}

- (NSString *)getFirstCharacterValueForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:1
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:1];
}

- (NSString *)getSecondAndThirdCharactersValueForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:2
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:1];
    
}

- (NSString *)getFourthCharacterValueForRow:(NSInteger)row isEnlisted:(BOOL)isEnlisted {
    NSArray *tempArray = [self getArrayForCharacterGroup:3
                                              isEnlisted:isEnlisted];
    
    return [[tempArray objectAtIndex:row] objectAtIndex:1];
    
}

@end

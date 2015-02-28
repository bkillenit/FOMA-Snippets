// Below is code for a time clock that clocks in and out salaried employees. This code is special to me because I found a way to make
// the functionality better than what was asked for in the design specifications and went above my boss's expectations.

// The interface comprised of a clock in and a clock out button. I configured the SQL call to tell the app what the latest clocking action 
// was, therefore making the clock status of a salaried employee persistent across devices assuming the user had internet access. 
// I also handled all of the edge cases associated with correctly recording the time data.

- (IBAction)clockBtnClk:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        NSString *clockTypePressed = [[sender titleLabel] text];
        if ([clockTypePressed isEqualToString:@"Clock In"]) {
            _currentEmployeeTime.clockType = @"Clock-in";
        } else if ([clockTypePressed isEqualToString:@"Clock Out"]) {
            if ([[self getLatestClockType] isEqualToString:@""]) {
                //alert the user that they must clock in for the day first
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"You have not yet clocked in for the day" message:@"Please clock yourself in before clocking out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            _currentEmployeeTime.clockType = @"Clock-out";
        } else {
            NSLog(@"Invalid clock type");
            return;
        }
        
        if ([self isLatestClockTypeDifferent]) {
            if ([self isClockTimeWithinBounds]) {
                [self clockEmployee];
            } else {
                NSString *alertContext = @"";
                if ([clockTypePressed isEqualToString:@"Clock In"]) {
                    alertContext = @"Clocking In Late";
                } else if ([clockTypePressed isEqualToString:@"Clock Out"]) {
                    alertContext = @"Clocking Out Early";
                }
                //bring up text input to supply reason
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertContext message:[NSString stringWithFormat:@"Please provide a short reason for you %@", [alertContext lowercaseString]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert show];
            }
        } else {
            NSString *alertContext = @"";
            if ([clockTypePressed isEqualToString:@"Clock In"]) {
                alertContext = @"in";
            } else if ([clockTypePressed isEqualToString:@"Clock Out"]) {
                alertContext = @"out";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You are already clocked %@", alertContext]
                                                            message:@"Please ensure that you clicked the correct button"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        NSLog(@"A button did not trigger this method");
    }
}

- (BOOL)isLatestClockTypeDifferent {
    return (![[self getLatestClockType] isEqualToString:_currentEmployeeTime.clockType]);
}

- (NSString *)getLatestClockType {
    return [[FOMAIMP shareInstance] latestClockTypeWithOrgId:_currentEmployeeTime.orgId withTimeClockId:0 withEmployeeId:_currentEmployeeTime.employeeId withUserType:_currentEmployeeTime.userType withClockDate:[FOMAUtil FOMADateToShortString:[FOMAUtil FOMAStringToDate:_currentEmployeeTime.clockDateTime]]];
}

- (BOOL)isClockTimeWithinBounds {
    BOOL result = FALSE;
    
    if ([_currentEmployeeTime.clockType isEqualToString:@"Clock-in"]) {
        result = !([_currentEmployeeTime.clockTime doubleValue] >= _maxClockInTime);
    } else if ([_currentEmployeeTime.clockType isEqualToString:@"Clock-out"]) {
        result = !([_currentEmployeeTime.clockTime doubleValue] <= _minClockOutTime);
    }
    
    return result;
}

- (void)clockEmployee {
    // creating new data object everytime that user is storing a time record so that
    // we can get record creation time precise to the second (Format: hh:mm:ss)
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm:ss" options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];

    _currentEmployeeTime.isOverride = NO;
    _currentEmployeeTime.timeCreated = todayString;
    _currentEmployeeTime.isSubmit = NO;
    _currentEmployeeTime.timeClockId = [[FOMAIMP shareInstance] setEmployeeClockTime:_currentEmployeeTime];
    if(_currentEmployeeTime.timeClockId>0)
    {
            // TODO: refactor this to be better and not submit an array, instead submit the currentEmployeeTime
            // to a different method or polymorphic method of this one
            NSMutableArray *employeeTimeArray = [[NSMutableArray alloc] initWithObjects:_currentEmployeeTime, nil];
            _currentEmployeeTime.isSubmit = YES;
            CLLocation *currentLocation = APPDELEGATE.currentLocation;
            // upload the new record to FOSA
            [[FOMAIMP shareInstance] submitTimesArray:employeeTimeArray withLongitude:currentLocation.coordinate.longitude withLatitude:currentLocation.coordinate.latitude];
    }
    else
    {
        [FOMAUtil FOMAAlertViewIsOk:@"Save unsuccessfully"];
    }
}
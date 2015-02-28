// DESCRIPTION: I am proud of this code because I found a fairly simple solution to a problem I initially thought was going to be 
// more complex. There is a scrollable panel on the application's home screen that displays personnel, weather, or job information 
// data depending on what panel the user has scrolled to. I implemented a dictionary ( format panelName:{elementName:pointer} ) 
// that contains pointers to all of the UI elements in the panels so that they can be updated dynamically. The meat of the code is
// contained in the first for loop (lines 7 - 87) and in the updatePanel function (lines 305 - 424).


// this for loop was implemented in a refresh subview function that is invoked both from the framework function viewDidAppear and
// everytime new panel data is received from the web backend.
for (int i = 0; i < viewsize; i++) {
    CGRect frame;
    frame.origin.x = self.pageScrollView.frame.size.width * i;
    frame.origin.y = 0;
    frame.size = self.pageScrollView.frame.size;

    UIView *subview = [[UIView alloc] initWithFrame:frame];
    subview.backgroundColor = [UIColor blackColor];

    CGRect subframe;
    subframe.origin.x = 10;
    subframe.origin.y = 10;
    subframe.size.width = 160;
    subframe.size.height =30;
    UILabel *label = [[UILabel alloc] initWithFrame:subframe];

    label.textColor = [UIColor whiteColor];
    [label setFont:[UIFont systemFontOfSize:18]];

    NSDictionary *panelUIObjects = [[NSMutableDictionary alloc] init];
    NSString *keytext = @"";

    if(i==1){
        label.text =@"Today's Weather";
        keytext = @"Weather";
        
        panelUIObjects = [self createWeatherSubview];
        // draw the constructed UIView objects with no data in them
        for (NSString *panelUIObject in panelUIObjects) {
            UIView *value = [panelUIObjects objectForKey:panelUIObject];
            [subview addSubview:value];
        }
    }else if(i==2)
    {
        label.text = @"Project Personnel";
        keytext = label.text;
        
        int personnelCount = _employeesData.count;
        panelUIObjects = [self createPersonnelSubview:personnelCount];
        
        UIScrollView *personnelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(subview.bounds.origin.x, 50, subview.bounds.size.width, subview.bounds.size.height - 50)];
        personnelScrollView.backgroundColor = [UIColor clearColor];
        for (NSString *panelUIObject in panelUIObjects) {
            UIView *value = [panelUIObjects objectForKey:panelUIObject];
            [personnelScrollView addSubview:value];
        }
        
        int rowCount = (personnelCount % 3) > 0 ? (personnelCount /3 + 1) : personnelCount /3;
        
        personnelScrollView.contentSize = CGSizeMake(personnelScrollView.frame.size.width, rowCount*110);
        
        [subview addSubview:personnelScrollView];
        
    }
    else{
        label.text =@"Job Information";
        keytext = label.text;
        
        panelUIObjects = [self createJobSubview];
        
        UIScrollView *jobScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(subview.bounds.origin.x, 50, subview.bounds.size.width, subview.bounds.size.height - 50)];
        jobScrollView.backgroundColor = [UIColor clearColor];
        
        for (NSString *panelUIObject in panelUIObjects) {
            UIView *value = [panelUIObjects objectForKey:panelUIObject];
            [jobScrollView addSubview:value];
        }
        
        jobScrollView.contentSize = CGSizeMake(jobScrollView.frame.size.width, panelUIObjects.count*28);
        
        [subview addSubview:jobScrollView];
    }

    [subview addSubview:label];

    // Storing the UI elements in the scrollviewUIObjects interface property for further use by
    // the controller at times that we need to update the panels outside of page loading
    // Dictionary Format: key: labeltext value: NSDictionary containing all of the UI objects
    [_scrollviewUIObjects setObject:panelUIObjects forKey: keytext];
    [self.pageScrollView addSubview:subview];
}

- (NSDictionary *)createWeatherSubview
{
    // TODO: switch weather data to be loaded when the user scrolls to the weather panel
    // Currently loading asynchronously with the loading of the home page
    
    if (_currentJob) _currentWeatherData = [self requestWeatherDataWithLat:_currentJob.latitude withLong:_currentJob.longitude];
    
    // // instantiating the loading spinner specific to the panel and settings it's location
    CGRect spinnerFrame = CGRectMake(150, 12, 25, 25);
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    [spinner startAnimating];
    
    // instantiating the temperature label and settings it's location
    CGRect temperatureSubFrame = CGRectMake(10, 40, 300, 30);
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureSubFrame];
    temperatureLabel.textColor = [UIColor whiteColor];
    [temperatureLabel setFont:[UIFont systemFontOfSize:18]];
    temperatureLabel.hidden = YES;
    
    // instantiating the min max temperature label and settings it's location
    CGRect temperatureMinMaxSubFrame = CGRectMake(10, 60, 150, 30);
    UILabel *temperatureMinMaxLabel = [[UILabel alloc] initWithFrame:temperatureMinMaxSubFrame];
    temperatureMinMaxLabel.textColor = [UIColor whiteColor];
    [temperatureMinMaxLabel setFont:[UIFont systemFontOfSize:18]];
    temperatureMinMaxLabel.hidden = YES;
    
    // instantiating the weather icon image and settings it's location
    CGRect weatherIconFrame = CGRectMake(215, 25, 60, 60);
    UIImageView *weatherIcon = [[UIImageView alloc] initWithFrame:weatherIconFrame];
    weatherIcon.contentMode = UIViewContentModeScaleAspectFit;
    weatherIcon.hidden = YES;
    
    // instantiating the precipitation label and settings it's location
    CGRect precipitationFrame = CGRectMake(10, 80, 200, 30);
    UILabel *precipitationLabel = [[UILabel alloc] initWithFrame:precipitationFrame];
    precipitationLabel.textColor = [UIColor whiteColor];
    [precipitationLabel setFont:[UIFont systemFontOfSize:18]];
    precipitationLabel.hidden = YES;
    
    // instantiating the wind speed label and settings it's location
    CGRect windSpeedFrame = CGRectMake(10, 100, 200, 30);
    UILabel *windSpeedLabel = [[UILabel alloc] initWithFrame:windSpeedFrame];
     windSpeedLabel.textColor = [UIColor whiteColor];
    [windSpeedLabel setFont:[UIFont systemFontOfSize:18]];
    windSpeedLabel.hidden = YES;
    
    // instantiating the humidity label and settings it's location
    CGRect humidityFrame = CGRectMake(175, 100, 200, 30);
    UILabel *humidityLabel = [[UILabel alloc] initWithFrame:humidityFrame];
    humidityLabel.textColor = [UIColor whiteColor];
    [humidityLabel setFont:[UIFont systemFontOfSize:18]];
    humidityLabel.hidden = YES;
    
    // will equally space out the elements below based on the entire frame's width in phase 2
    NSMutableArray *upcomingDays =  [Weather getUpcomingDaysOfWeek];
    
    // instantiating the next day label and settings it's location
    CGRect nextDayFrame = CGRectMake(127, 130, 40, 30);
    UILabel *nextDayLabel = [[UILabel alloc] initWithFrame:nextDayFrame];
    nextDayLabel.textColor = [UIColor whiteColor];
    [nextDayLabel setFont:[UIFont systemFontOfSize:15]];
    if ([upcomingDays count]>0) {
     nextDayLabel.text = [[upcomingDays objectAtIndex:0] substringToIndex:3];
    }
    nextDayLabel.textAlignment = NSTextAlignmentCenter;
    nextDayLabel.hidden = YES;
    
    // instantiating the two day label and settings it's location
    CGRect twoDayFrame = CGRectMake(187, 130, 40, 30);
    UILabel *twoDayLabel = [[UILabel alloc] initWithFrame:twoDayFrame];
    twoDayLabel.textColor = [UIColor whiteColor];
    [twoDayLabel setFont:[UIFont systemFontOfSize:15]];
    if ([upcomingDays count]>1) {
    twoDayLabel.text = [[upcomingDays objectAtIndex:1] substringToIndex:3];
    }
    twoDayLabel.textAlignment = NSTextAlignmentCenter;
    twoDayLabel.hidden = YES;
    
    // instantiating the three day label and settings it's location
    CGRect threeDayFrame = CGRectMake(247, 130, 40, 30);
    UILabel *threeDayLabel = [[UILabel alloc] initWithFrame:threeDayFrame];
    threeDayLabel.textColor = [UIColor whiteColor];
    [threeDayLabel setFont:[UIFont systemFontOfSize:15]];
    if ([upcomingDays count]>2) {
    threeDayLabel.text = [[upcomingDays objectAtIndex:2] substringToIndex:3];
    }
    threeDayLabel.textAlignment = NSTextAlignmentCenter;
    threeDayLabel.hidden = YES;
    
    // instantiating the next day icon image and settings it's location
    CGRect nextDayIconFrame = CGRectMake(129, 155, 40, 40);
    UIImageView *nextDayIcon = [[UIImageView alloc] initWithFrame:nextDayIconFrame];
    nextDayIcon.contentMode = UIViewContentModeScaleAspectFit;
    nextDayIcon.hidden = YES;
    
    // instantiating the two day icon image and settings it's location
    CGRect twoDayIconFrame = CGRectMake(189, 155, 40, 40);
    UIImageView *twoDayIcon = [[UIImageView alloc] initWithFrame:twoDayIconFrame];
    twoDayIcon.contentMode = UIViewContentModeScaleAspectFit;
    twoDayIcon.hidden = YES;
    
    // instantiating the three day icon image and settings it's location
    CGRect threeDayIconFrame = CGRectMake(249, 155, 40, 40);
    UIImageView *threeDayIcon = [[UIImageView alloc] initWithFrame:threeDayIconFrame];
    threeDayIcon.contentMode = UIViewContentModeScaleAspectFit;
    threeDayIcon.hidden = YES;
    
    // instantiating the next day min max label and settings it's location
    CGRect nextDayMinMaxFrame = CGRectMake(128, 190, 50, 30);
    UILabel *nextDayMinMaxLabel = [[UILabel alloc] initWithFrame:nextDayMinMaxFrame];
    nextDayMinMaxLabel.textColor = [UIColor whiteColor];
    [nextDayMinMaxLabel setFont:[UIFont systemFontOfSize:13]];
    nextDayMinMaxLabel.textAlignment = NSTextAlignmentCenter;
    nextDayMinMaxLabel.hidden = YES;
    
    // instantiating the two day min max label and settings it's location
    CGRect twoDayMinMaxFrame = CGRectMake(188, 190, 50, 30);
    UILabel *twoDayMinMaxLabel = [[UILabel alloc] initWithFrame:twoDayMinMaxFrame];
    twoDayMinMaxLabel.textColor = [UIColor whiteColor];
    [twoDayMinMaxLabel setFont:[UIFont systemFontOfSize:13]];
    twoDayMinMaxLabel.textAlignment = NSTextAlignmentCenter;
    twoDayMinMaxLabel.hidden = YES;
    
    // instantiating the three day min max label and settings it's location
    CGRect threeDayMinMaxFrame = CGRectMake(248, 190, 50, 30);
    UILabel *threeDayMinMaxLabel = [[UILabel alloc] initWithFrame:threeDayMinMaxFrame];
    threeDayMinMaxLabel.textColor = [UIColor whiteColor];
    [threeDayMinMaxLabel setFont:[UIFont systemFontOfSize:13]];
    threeDayMinMaxLabel.textAlignment = NSTextAlignmentCenter;
    threeDayMinMaxLabel.hidden = YES;
    
    NSArray *keys = @[@"spinner",@"temperatureLabel",@"temperatureMinMaxLabel",@"weatherIcon",@"precipitationLabel",@"windSpeedLabel",@"humidityLabel",@"nextDayLabel",@"twoDayLabel",@"threeDayLabel",@"nextDayIcon",@"twoDayIcon",@"threeDayIcon",@"nextDayMinMaxLabel",@"twoDayMinMaxLabel",@"threeDayMinMaxLabel"];
    NSArray *values = @[spinner,temperatureLabel,temperatureMinMaxLabel,weatherIcon,precipitationLabel,windSpeedLabel,humidityLabel,nextDayLabel,twoDayLabel,threeDayLabel,nextDayIcon,twoDayIcon,threeDayIcon,nextDayMinMaxLabel,twoDayMinMaxLabel,threeDayMinMaxLabel];
    NSDictionary *weatherUIObjects = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return  weatherUIObjects;
}

-(NSDictionary *)createJobSubview
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];

    // // instantiating the loading spinner specific to the panel and settings it's location
    //CGRect spinnerFrame = CGRectMake(85, 12, 25, 25);
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    
    CGRect labelFrame;
    labelFrame.size.width = 260;
    labelFrame.size.height = 20;
    labelFrame.origin.x = 10;
    
    labelFrame.origin.y = 50 - 50;
    // instantiating the temperature label and settings it's location
    UILabel *clientNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    clientNameLabel.textColor = [UIColor whiteColor];
    [clientNameLabel setFont:[UIFont systemFontOfSize:13]];
    clientNameLabel.hidden = YES;
    [values addObject:clientNameLabel];
    [keys addObject:@"Client"];
    
    labelFrame.origin.y = 75 - 50;
    // instantiating the max temperature label and settings it's location
    UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    projectNameLabel.textColor = [UIColor whiteColor];
    [projectNameLabel setFont:[UIFont systemFontOfSize:13]];
    projectNameLabel.hidden = YES;
    [values addObject:projectNameLabel];
    [keys addObject:@"Project"];
    
    labelFrame.origin.y = 100 + (_currentJob.contactList.count*25) - 50;
    // instantiating the max temperature label and settings it's location
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:labelFrame];
    timeLabel.textColor = [UIColor whiteColor];
    [timeLabel setFont:[UIFont systemFontOfSize:13]];
    timeLabel.hidden = YES;
    [values addObject:timeLabel];
    [keys addObject:@"SyncTime"];


    for (int i = 0; i < _currentJob.contactList.count; i++)
    {
        labelFrame.origin.y = 100 + (i*25) - 50;
        
        JobContact *contact = [_currentJob.contactList objectAtIndex:i];
        
        UILabel *jobLabel = [[UILabel alloc] initWithFrame:labelFrame];
        jobLabel.textColor = [UIColor whiteColor];
        [jobLabel setFont:[UIFont systemFontOfSize:13]];
        jobLabel.hidden = YES;
        [values addObject:jobLabel];
        [keys addObject:contact.label];
    }
        
    NSDictionary *jobUIObjects = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    return jobUIObjects;
}

- (NSDictionary *)createPersonnelSubview:(int)count
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for(int i = 0; i < count;i++)
    {
        CGRect imageViewFrame = CGRectMake(18+(i%9%3)*95, 10+(i%9/3)*105+(i/9)*320, 80, 90);
        UIImageView *headImageView=[[UIImageView alloc] initWithFrame:imageViewFrame];
        headImageView.backgroundColor = [UIColor blackColor];
        [keys addObject:[NSNumber numberWithInt:i]];
        [values addObject:headImageView];
    }
    
    NSDictionary *personnelUIObjects = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    return personnelUIObjects;
}

- (void)updatePanel:(NSString *)panel
{
    NSMutableDictionary *panelUIElements = (NSMutableDictionary  *)[_scrollviewUIObjects objectForKey:panel];
    
    if ([panel isEqualToString:@"Weather"]) {
        // update the weather panel
        UILabel *temperatureLabel = (UILabel  *)[panelUIElements objectForKey:@"temperatureLabel"];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[panelUIElements objectForKey:@"spinner"];
        
        if (_currentWeatherData) {
            UILabel *temperatureMinMaxLabel = (UILabel  *)[panelUIElements objectForKey:@"temperatureMinMaxLabel"];
            UIImageView *weatherIcon = (UIImageView *)[panelUIElements objectForKey:@"weatherIcon"];
            UILabel *precipitationLabel = (UILabel  *)[panelUIElements objectForKey:@"precipitationLabel"];
            UILabel *windSpeedLabel = (UILabel  *)[panelUIElements objectForKey:@"windSpeedLabel"];
            UILabel *humidityLabel = (UILabel  *)[panelUIElements objectForKey:@"humidityLabel"];
            UILabel *nextDayLabel = (UILabel  *)[panelUIElements objectForKey:@"nextDayLabel"];
            UILabel *twoDayLabel = (UILabel  *)[panelUIElements objectForKey:@"twoDayLabel"];
            UILabel *threeDayLabel = (UILabel  *)[panelUIElements objectForKey:@"threeDayLabel"];
            UIImageView *nextDayIcon = (UIImageView  *)[panelUIElements objectForKey:@"nextDayIcon"];
            UIImageView *twoDayIcon = (UIImageView  *)[panelUIElements objectForKey:@"twoDayIcon"];
            UIImageView *threeDayIcon = (UIImageView *)[panelUIElements objectForKey:@"threeDayIcon"];
            UILabel *nextDayMinMaxLabel = (UILabel  *)[panelUIElements objectForKey:@"nextDayMinMaxLabel"];
            UILabel *twoDayMinMaxLabel = (UILabel  *)[panelUIElements objectForKey:@"twoDayMinMaxLabel"];
            UILabel *threeDayMinMaxLabel = (UILabel  *)[panelUIElements objectForKey:@"threeDayMinMaxLabel"];
            
            temperatureLabel.text = [NSString stringWithFormat: @"Temperature: %d ℉", _currentWeatherData.temperatureFahrenheit];
            temperatureMinMaxLabel.text = [NSString stringWithFormat: @"Min/Max: %d/%d", _currentWeatherData.temperatureMin,_currentWeatherData.temperatureMax];
            precipitationLabel.text = [NSString stringWithFormat: @"Precipitation: %.f%%", _currentWeatherData.precipitation*100];
            windSpeedLabel.text = [NSString stringWithFormat: @"Wind: %d mph", _currentWeatherData.windSpeed];
            humidityLabel.text = [NSString stringWithFormat: @"Humidity: %.f%%", _currentWeatherData.humidity*100];
            [weatherIcon setImage:[UIImage imageNamed:[Weather iconImageFor:_currentWeatherData.icon]]];
            [nextDayIcon setImage:[UIImage imageNamed:[Weather iconImageFor:_currentWeatherData.nextDayIcon]]];
            [twoDayIcon setImage:[UIImage imageNamed:[Weather iconImageFor:_currentWeatherData.twoDaysIcon]]];
            [threeDayIcon setImage:[UIImage imageNamed:[Weather iconImageFor:_currentWeatherData.threeDaysIcon]]];
            nextDayMinMaxLabel.text = [NSString stringWithFormat: @"%d/%d", _currentWeatherData.nextDayMin,_currentWeatherData.nextDayMax];
            twoDayMinMaxLabel.text = [NSString stringWithFormat: @"%d/%d", _currentWeatherData.twoDaysMin,_currentWeatherData.twoDaysMax];
            threeDayMinMaxLabel.text = [NSString stringWithFormat: @"%d/%d", _currentWeatherData.threeDaysMin,_currentWeatherData.threeDaysMax];
            
            temperatureMinMaxLabel.hidden = NO;
            weatherIcon.hidden = NO;
            precipitationLabel.hidden = NO;
            windSpeedLabel.hidden = NO;
            humidityLabel.hidden = NO;
            nextDayLabel.hidden = NO;
            twoDayLabel.hidden = NO;
            threeDayLabel.hidden = NO;
            nextDayIcon.hidden = NO;
            twoDayIcon.hidden = NO;
            threeDayIcon.hidden = NO;
            nextDayMinMaxLabel.hidden = NO;
            twoDayMinMaxLabel.hidden = NO;
            threeDayMinMaxLabel.hidden = NO;
            [spinner stopAnimating];
        } else {
            temperatureLabel.text = [NSString stringWithFormat: @"Temperature for job not found"];
            [spinner stopAnimating];
        }
        temperatureLabel.hidden = NO;
    }
    else if ([panel isEqualToString:@"Project Personnel"]) {
        // update the project personnel panel
        
        for (NSString *panelkey in panelUIElements)
        {
            if (_employeesData.count == 0)
            {
                break;
            }
            
            Employee *user = [_employeesData objectAtIndex:[panelkey intValue]];
            if (user.employeeImageList.count == 0)
            {
                break;
            }
            EmployeeImage *image = [user.employeeImageList objectAtIndex:0];
            NSString *urlStr = [NSString stringWithFormat:@"%@Images/%@",API_HOST,image.imageName];
            UIImageView *headImageView = [panelUIElements objectForKey:panelkey];
            [headImageView  setImageWithURL:[NSURL URLWithString:urlStr]];
            
        }
        

    }
    else if ([panel isEqualToString:@"Job Information"]) {
        // update the job information panel
        if(_currentJob) {
            
            UILabel *clientNameLabel = (UILabel *)[panelUIElements objectForKey:@"Client"];
            clientNameLabel.text = [NSString stringWithFormat:@"Client: %@",_currentJob.clientName];
            clientNameLabel.hidden = NO;
            UILabel *projectNameLabel = (UILabel  *)[panelUIElements objectForKey:@"Project"];
            projectNameLabel.text = [NSString stringWithFormat:@"Project: %@",_currentJob.jobName];
            projectNameLabel.hidden = NO;

            UILabel *timeLabel = (UILabel  *)[panelUIElements objectForKey:@"SyncTime"];

            NSString * lastDataSyncStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"SyncTime"];
            NSDate * lastDataSync = [FOMAUtil FOMAStringToDate:lastDataSyncStr];
            timeLabel.text = [NSString stringWithFormat:@"Last Data Sync: %@",[FOMAUtil FOMADateToShortString:lastDataSync]];
            
            timeLabel.hidden = NO;
            for (int i = 0; i < _currentJob.contactList.count; i++)
            {
                JobContact *contact = [_currentJob.contactList objectAtIndex:i];
                UILabel *label = (UILabel *)[panelUIElements objectForKey:contact.label];
                label.text = [NSString stringWithFormat:@"%@: %@",contact.label,contact.userName];
                label.hidden = NO;
            }
        }        
    }
    else if ([panel isEqualToString:@"all"]) {
        [self updatePanel: @"Weather"];
        [self updatePanel: @"Project Personnel"];
        [self updatePanel: @"Job Information"];
    }
    else {
        // the panel provided by the caller is nonexistent
        NSLog(@"Incorrect/mispelled ScrollView panel provided");
    }
}
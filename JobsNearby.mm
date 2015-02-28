// This function calculates the distance away each job in the database is from the user's current location and then sorts
// the jobs in order of distance, removing the jobs from the list that are further than a user defined distance. I originally
// implemented this function using quick sort and computed the distance of each location of the user in linear time before
// the sorting was ran. I then removed jobs farther awway than desired after the sorting was performed.
//
// I am proud of this code snippet because I incerased the performance of the algorithm and sorting by first removing any job that 
// was too far away from the user at the same time the distances were being calculated, thus guaranteeing a smaller, if not significantly
// smaller, data set for the sorting algorithm to work on, which allowed me to sort using selection sort instead. A reasoning behind
// the choice of sorting algorithm starts on line 29.

+ (NSMutableArray *)calculateDistanceAndSortArray:(NSMutableArray *)array ByCurrentLocation:(CLLocation *)currentLocation
{
    if ([array count] > 1) {
        // calculate the distance of the job from the current location and update the distance property of our Job objects stored in the array
        // remove any jobs from the array that are further away than the preferred distance in miles, according to FOSA
        for (int i = 0; i < [array count]; i++) {
            CLLocation *jobLocation = [[CLLocation alloc] initWithLatitude:[[array objectAtIndex:i] latitude] longitude:[[array objectAtIndex:i] longitude] ];
            float distance = [currentLocation distanceFromLocation:jobLocation] * MILES_PER_METER;
            NSLog(@"job distance: %f", distance);

            if (distance > [[User shareInstance].defaultConfig.locationMile floatValue]) {
                [array removeObjectAtIndex:i];
                i--;
            } else {
                [[array objectAtIndex:i] setDistance:distance];
            }
        }
        
        // sort the array using selection sort in order from lowest to highest distance. O(n^2) complexity.
        // Chose this sorting method as the selection sort performs extremely well on small list and no additional
        // storage is required. Having a small list is a safe assumption as the list of jobs will be small after 
        // being filtered down based on the user defined max distance. Chose this algorithm over quick sort as
        // I assumed that most of the time we would be getting average or worst case running times, and therefore
        // would not need to incure the computing overhead involved in quick sort for marginal gains in sort speed.
        for (int i = 0; i < [array count]; i++) {
            float min = [[array objectAtIndex:i] distance];
            unsigned minIndex = i;
            
            for (int j = i+1; j < [array count]; j++) {
                float current = [[array objectAtIndex:j] distance];
                if (current < min) {
                    min = current;
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                Job *temp = [array objectAtIndex:minIndex];
                [array removeObjectAtIndex:minIndex];
                [array insertObject:temp atIndex:i];
            }
        }
    }
    
    return array;
}
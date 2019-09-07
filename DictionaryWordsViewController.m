//
//  DictionaryWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWordsViewController.h"
#import "DictionaryWord+Select.h"
#import "DictionaryWord+Delete.h"
#import "WordCell.h"
#import "WordDetailsViewController.h"

#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"

@interface DictionaryWordsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *wordsTableView;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
//@property (nonatomic, strong) NSArray *dictionaryWords;

@property (nonatomic, strong) UIManagedDocument *database;

@property (nonatomic, strong) NSIndexPath *accessoryButtonSelectedIndexPath;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation DictionaryWordsViewController

@synthesize audioPlayer = _audioPlayer;
@synthesize database = _database;
@synthesize accessoryButtonSelectedIndexPath = _accessoryButtonSelectedIndexPath;

- (void) setDatabase:(UIManagedDocument *)database
{
    if(_database != database) {
        _database = database; 
    }
}
/*
- (NSArray *) dictionaryWords
{
    //lazy instantiation
    _dictionaryWords = [DictionaryWord selectAllDictionaryWords:self.database.managedObjectContext];
    
    return _dictionaryWords;
}
 */

- (IBAction)dictionarySearchButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES]; 
}
/*
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dictionaryWords count];
}
*/

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Word Cell";
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[WordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    DictionaryWord *dictionaryWord = //[self.dictionaryWords objectAtIndex:[indexPath row]];
                                [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.wordLabel.text = dictionaryWord.foreign;
    cell.transcriptionLabel.text = dictionaryWord.transcription;
    cell.translationLabel.text = dictionaryWord.native;
    [cell.wordImage setImage: [UIImage imageWithData: dictionaryWord.image]];
    
    UIImage *recordingImage = [UIImage imageNamed:@"detail_arrow.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(44.0, 44.0, recordingImage.size.width/2, recordingImage.size.height/2);
    button.frame = frame;
    [button setBackgroundImage:recordingImage forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(accessoryButtonTapped:event:)
     forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row at WordTableView.");
    
    NSString *audioPath = //[[self.dictionaryWords objectAtIndex:[indexPath row]] recording];
    [[self.fetchedResultsController objectAtIndexPath:indexPath] recording];
    
    NSString *urlAsString = kWORD_RECORDING_SERVICE_URL;
    urlAsString = [urlAsString stringByAppendingString: audioPath];
    NSLog(@"Audio Full Path: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    dispatch_async(dispatch_queue_create("com.company.app.audioQueue", NULL), ^{
        NSData *audioData = [NSData dataWithContentsOfURL: url];
        
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error:&error];
        
        if(error) {
            NSLog(@"Error playing audio: %@",[error description]);
        } else {
            NSLog(@"Playing recording of word");
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    });
}

- (void)accessoryButtonTapped:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.wordsTableView];
    NSIndexPath *indexPath = [self.wordsTableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        [self tableView: self.wordsTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Accessory Button Tapped - Manual Word Details Segue");
    self.accessoryButtonSelectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Word Details Segue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //ListOfWordsViewController *viewcontroller
    if([segue.identifier isEqualToString:@"Word Details Segue"]) {
        NSLog(@"Prepare For Word Details Segue");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DictionaryWord *dictionaryWord =  //[self.dictionaryWords objectAtIndex: [self.accessoryButtonSelectedIndexPath row]];
            [self.fetchedResultsController objectAtIndexPath: self.accessoryButtonSelectedIndexPath];
            WordObject *wordObject = [[WordObject alloc] initWithWID:dictionaryWord.wordId
                                                         foreignName:dictionaryWord.foreign
                                                          nativeName:dictionaryWord.native
                                                           imagePath:nil
                                                           audioPath:dictionaryWord.recording
                                                       transcription:dictionaryWord.transcription
                                                      foreignArticle:@""
                                                       nativeArticle:@""];
            wordObject.image = [UIImage imageWithData:dictionaryWord.image];
            wordObject.imageLoaded = YES;
            
            [segue.destinationViewController setWordObject: wordObject];
            
        });
        
    } 
}

- (IBAction)trashBarButtonTouched:(UIBarButtonItem *)sender {
    
    NSLog(@"Trash Bar Button Touched.");
    //if([[self.dictionaryWords count] > 0) {
    if([[self.fetchedResultsController fetchedObjects] count] > 0) {
        NSIndexPath *indexPath = [self.wordsTableView indexPathForSelectedRow];
        [self.database.managedObjectContext performBlock:^{
             [self deleteWordAtIndexPath:indexPath];
        }];
       
    }
}

- (void) deleteWordAtIndexPath: (NSIndexPath *) indexPath
{
    //removing object in data source for given indexPath
    //DictionaryWord *word = [self.dictionaryWords objectAtIndex:[indexPath row]];
    //if([DictionaryWord deleteWord: word]) {
        NSLog(@"DictionaryWord deleted in data source.");
        //checking an retrieving new set of word from Core Data
        [self.fetchedResultsController.managedObjectContext deleteObject:
         [self.fetchedResultsController objectAtIndexPath:indexPath]];
       // self.dictionaryWords = [DictionaryWord selectAllDictionaryWords:self.database.managedObjectContext];
        //deleting row at tableView to reflect deletion in data source
        //[self.wordsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
   // }

}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"Swipe-to-Delete, Delete button touched.");
        [self.database.managedObjectContext performBlock:^{
            [self deleteWordAtIndexPath:indexPath];
        }];
    }
}

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DictionaryWord"];
    /* we want all categories, we don't specify predicate */
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Saved Words";
    [self adjustToScreenOrientation];
}

- (void)awakeFromNib
{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToScreenOrientation];
}

- (void) adjustToScreenOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"london.png"]];
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
}

- (IBAction)dictionaryButtonTouched:(id)sender {
    [self.delegate segueToDictionaryView];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"DictionaryWords View Did Appear.");
    self.tableView = self.wordsTableView;
    [self setupFetchedResultsController];
}

- (void)viewDidUnload {
    [self setWordsTableView:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end

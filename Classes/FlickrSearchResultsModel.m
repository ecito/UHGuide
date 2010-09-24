//
//  FlickrSearchResultsModel.m
//
//  Created by Keith Lazuka on 7/23/09.
//  
//

#import "FlickrSearchResultsModel.h"
#import "FlickrJSONResponse.h"
#import "GTMNSDictionary+URLArguments.h"

const static NSUInteger kFlickrBatchSize = 16;   // The number of results to pull down with each request to the server.

@implementation FlickrSearchResultsModel


- (id)initWithResponseFormat:(SearchResponseFormat)responseFormat;
{
    if ((self = [super init])) {
        switch ( responseFormat ) {
            case SearchResponseFormatJSON:
                responseProcessor = [[FlickrJSONResponse alloc] init];
                break;
            default:
                [NSException raise:@"SearchResponseFormat unknown!" format:nil];
        }
        page = 1;
    }
    return self;
}

- (id)init
{
    return [self initWithResponseFormat:CurrentSearchResponseFormat];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
    
    if (more)
        page++;
    else
        [responseProcessor.objects removeAllObjects]; // Clear out data from previous request.
    
    NSString *batchSize = [NSString stringWithFormat:@"%lu", (unsigned long)kFlickrBatchSize];
	
    // Construct the request.
    NSString *host = @"http://api.flickr.com";
    NSString *path = @"/services/rest/";
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"flickr.groups.pools.getPhotos", @"method",
                                @"354564@N25", @"group_id",
                                @"url_m,url_t", @"extras",
                                @"a5296f05fa7e1f04ebbaa1c6772932b2", @"api_key", 
                                [responseProcessor format], @"format",
                                [NSString stringWithFormat:@"%lu", (unsigned long)page], @"page",
                                batchSize, @"per_page",
                                @"1", @"nojsoncallback",
                                nil];
            
    NSString *url = [host stringByAppendingFormat:@"%@?%@", path, [parameters gtm_httpArgumentsString]];
    TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];
    request.cachePolicy = cachePolicy;
    request.response = responseProcessor;
    request.httpMethod = @"GET";
    
    // Dispatch the request.
    [request send];
}

- (void)reset
{
    [super reset];
    page = 1;
    [[responseProcessor objects] removeAllObjects];
}


- (NSArray *)results
{
    return [[[responseProcessor objects] copy] autorelease];
}

- (NSUInteger)totalResultsAvailableOnServer
{
    return [responseProcessor totalObjectsAvailableOnServer];
}

- (void)dealloc
{
    [responseProcessor release];
    [super dealloc];
}


@end

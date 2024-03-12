// UIKit+AFNetworkingCustom.h
//
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <TargetConditionals.h>

#ifndef _UIKIT_el-grocer-shopper-sdk-iOS_
    #define _UIKIT_el-grocer-shopper-sdk-iOS_

#if TARGET_OS_IOS || TARGET_OS_TV
    #import "AFAutoPurgingImageCacheCustom.h"
    #import "AFImageDownloaderCustom.h"
    #import "UIActivityIndicatorView+AFNetworkingCustom.h"
    #import "UIButton+AFNetworkingCustom.h"
    #import "UIImageView+AFNetworkingCustom.h"
    #import "UIProgressView+AFNetworkingCustom.h"
#endif

#if TARGET_OS_IOS
    #import "AFNetworkActivityIndicatorManagerCustom.h"
    #import "UIRefreshControl+AFNetworkingCustom.h"
    #import "WKWebView+AFNetworkingCustom.h"
#endif

#endif /* _UIKIT_AFNETWORKING_ */

import { ViewProps, HostComponent, ProcessedColorValue, StyleProp, ViewStyle } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import type {
    Float,
    BubblingEventHandler,
    WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';

export type UrlPropsType = {
    /**
     * `method` is the HTTP Method to use. Defaults to GET if not specified.
     */
    method?: string,

    /**
     * `headers` is an object representing the HTTP headers to send along with the
     * request for a remote image.
     */
    headers?: { [key: string]: string },

    /**
     * `body` is the HTTP body to send with the request. This must be a valid
     * UTF-8 string, and will be sent exactly as specified, with no
     * additional encoding (e.g. URL-escaping or base64) applied.
     */
    body?: string,
};


export interface PDFViewUrlProps {
    /**
     * `method` is the HTTP Method to use. Defaults to GET if not specified.
     */
    method?: string;

    /**
     * `headers` is an object representing the HTTP headers to send along with the
     * request for a remote image.
     */
    // headers?: Record<string,string>;

    headers?: Readonly<{}>;
    // ReadonlyArray<Readonly<{name: string, value: string}>>
    /**
     * `body` is the HTTP body to send with the request. This must be a valid
     * UTF-8 string, and will be sent exactly as specified, with no
     * additional encoding (e.g. URL-escaping or base64) applied.
     */
    body?: string;
}


export interface PDFViewProps extends ViewProps {
    /**
     * `style` View Style Property https://reactnative.dev/docs/view-style-props
     *
    /**
     * A Function. Invoked on load error with {nativeEvent: {error}}.
     */
    onError?: BubblingEventHandler<{ error: { message: string } }>;

    /**
     * A Function. Invoked when load completes successfully.
     */
    onLoad?: BubblingEventHandler<Readonly<{}>>;

    /**
     * A Function. Invoked when page is changed.
     * @param {Number} page - The active page.
     * @param {Number} pageCount - Total pages.
     */
    onPageChanged?: BubblingEventHandler<Readonly<{ page: Float, pageCount: Float }>>;

    /**
     * A Function. Invoked when page is scrolled.
     * @param {Number} offset - Offset. Currently only 1 and 0 are supported.
     *                          where:
     *                            0 - beginning of the document
     *                            1 - end of the document
     */
    onScrolled?: BubblingEventHandler<Readonly<{ offset: Float }>>;

    /**
     * A String value. Defines the resource to render. Can be one of:
     *   - url. Example: http://www.pdf995.com/samples/pdf.pdf
     *   - base64. Example: 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50...'
     *   - fileName - Example: Platform.OS === 'ios' ?
     *       'test-pdf.pdf' : '/sdcard/Download/test-pdf.pdf'
     */
    resource: string,

    /**
     * A String value. Defines the resource type. Can be one of:
     *   - "url", for url
     *   - "base64", for base64 data
     *   - "file", for local files
     */
    resourceType?: WithDefault<'url' | 'base64' | 'file', 'url'>;

    /**
     * iOS file location. Can be one of:
     *   - "bundle"
     *   - "documentsDirectory"
     *   - "libraryDirectory"
     *   - "cachesDirectory"
     *   - "tempDirectory"
     */
    fileFrom?: WithDefault<| 'files'|'cache'|'temp'|'bundle'
        | 'documentsDirectory'
        | 'libraryDirectory'
        | 'cachesDirectory'
        | 'tempDirectory', 'files'>;

    /**
     * Extended props for "url" resource type
     */
    urlProps?: PDFViewUrlProps,

    /**
     * A String value. Defines encoding type. Can be one of:
     *   - "utf-8", default
     *   - "utf-16"
     */
    textEncoding?: WithDefault<'utf-8' | 'utf-16', 'utf-8'>,

    /**
     * A Number value. Fades in the webview (in ms) on load successfully (iOS Only):
     *   - 0.0, default
     */
    fadeInDuration?: Float,

    /**
     * A Boolean value. Enables annotations view on Android
     *   - false, default
     */
    enableAnnotations?: boolean,
}

type NativeType = HostComponent<PDFViewProps>;
interface NativeCommands {
    reload: (viewRef: React.ElementRef<NativeType>,) => Promise<void>
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
    supportedCommands: ['reload'],
});


/**
 * codegen restriction: the result of codegenNativeComponent must be a default export
 */
export default codegenNativeComponent<PDFViewProps>(
    'PDFView'
) as HostComponent<PDFViewProps>;

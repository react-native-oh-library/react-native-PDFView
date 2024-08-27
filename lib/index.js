import PDFViewOther from 'react-native-view-pdf';
import PDFViewHarmony from '../src/NativePDFViewComponent';
import { Platform } from 'react-native';
const isIosAndroid = Platform.OS === 'ios' || Platform.OS === 'android';
const PDFView = isIosAndroid ? PDFViewOther : PDFViewHarmony;
export default PDFView;

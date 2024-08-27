import { RNPackage, TurboModulesFactory } from '@rnoh/react-native-openharmony/ts';
import type {
  DescriptorWrapperFactoryByDescriptorTypeCtx,
  DescriptorWrapperFactoryByDescriptorType
} from '@rnoh/react-native-openharmony/ts';
import {  RNC } from "@rnoh/react-native-openharmony/generated/ts"

export class PDFViewPackage extends RNPackage {
  createDescriptorWrapperFactoryByDescriptorType(ctx: DescriptorWrapperFactoryByDescriptorTypeCtx): DescriptorWrapperFactoryByDescriptorType {
    return { [RNC.RNPDFView.NAME]: (ctx2) => new RNC.RNPDFView.DescriptorWrapper(ctx2.descriptor) }
  }
}

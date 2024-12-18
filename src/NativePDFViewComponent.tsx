/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import React, { useRef } from 'react';
import PDFComponent, { PDFViewProps, PDFViewUrlProps } from './NativePDFView';
import { UIManager, findNodeHandle, HostComponent, ViewStyle, StyleProp, Platform } from 'react-native';
import { Float } from 'react-native/Libraries/Types/CodegenTypes';

export type GeneratedSampleComponentRef = {
  reload: () => Promise<void>;
};

type onErrType = {
  message: string
}

type pageChangedType = {
  page: Float,
  pageCount: Float
}

type scrolledType = {
  offset: Float
}

const PDFView = React.forwardRef<
  GeneratedSampleComponentRef,
  {
    style?: StyleProp<ViewStyle>,
    resource: string,
    resourceType?: 'url' | 'base64' | 'file',
    textEncoding?: 'utf-8' | 'utf-16',
    fileFrom?:'files' | 'cache' | 'temp' | 'bundle' | 'documentsDirectory' | 'libraryDirectory' | 'cachesDirectory' | 'tempDirectory',
    urlProps?: PDFViewUrlProps
    fadeInDuration?: Float
    enableAnnotations?: boolean
    onLoad?: () => void;
    onError?: (args: onErrType) => void;
    onPageChanged?: (args: pageChangedType) => void;
    onScrolled?: (args: scrolledType) => void;

  }>(
    (
      {
        style,
        resource,
        resourceType,
        urlProps,
        fadeInDuration,
        enableAnnotations,
        textEncoding,
        fileFrom,
        onLoad,
        onError,
        onPageChanged,
        onScrolled
      },
      ref
    ) => {
      const pdfViewRef = useRef<React.ComponentRef<
        HostComponent<PDFViewProps>
      > | null>(null);
      React.useImperativeHandle(
        ref,
        () => ({
          async reload(): Promise<void> {
            const handle = findNodeHandle(pdfViewRef.current);
            if (!handle) {
              throw new Error('Cannot find node handles');
            }
            if (pdfViewRef?.current) {
              UIManager.dispatchViewManagerCommand(
                findNodeHandle(pdfViewRef.current),
                'reload',
                []
              )
            } else {
              throw new Error("No ref to PDFView component, check that component is mounted");
            }
          },
        }),
        []
      );
      return (
        <PDFComponent
          style={style}
          ref={pdfViewRef}
          resource={resource}
          resourceType={resourceType}
          urlProps={urlProps}
          fileFrom={fileFrom}
          fadeInDuration={fadeInDuration}
          enableAnnotations={enableAnnotations}
          textEncoding={textEncoding}
          onLoad={() => {
            onLoad?.()
          }}
          onError={(e) => {
            onError?.(e.nativeEvent.error)
          }}
          onPageChanged={(e) => {
            onPageChanged?.(e.nativeEvent)
          }}
          onScrolled={(e) => {
            onScrolled?.(e.nativeEvent)
          }}
        />
      );
    }
  );

export default PDFView;

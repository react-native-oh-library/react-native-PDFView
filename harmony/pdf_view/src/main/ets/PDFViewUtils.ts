/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import { RNC } from "@rnoh/react-native-openharmony/generated/ts"

/**
 * 获取直接属性
 * @param descriptorWrapper RNPDFView的描述符包装器
 * @return 返回一个对象，其键为RNPDFView的直接原始属性，值为任意类型
 */
export function getDirectProps(descriptorWrapper: RNC.RNPDFView.DescriptorWrapper ): Record<keyof RNC.RNPDFView.DirectRawProps, any> {
  // 从描述符包装器中获取属性
  const props = descriptorWrapper.props
  // 返回一个对象，其键为RNPDFView的直接原始属性，值为对应的属性值
  return {
    resource:props.resource, // 资源
    resourceType:props.resourceType, // 资源类型
    urlProps:props.urlProps, // URL属性
    fadeInDuration:props.fadeInDuration, // 淡入持续时间
    enableAnnotations:props.enableAnnotations, // 启用注释
    textEncoding:props.textEncoding, // 文本编码
    fileFrom:props.fileFrom // 文件来源
  }
}

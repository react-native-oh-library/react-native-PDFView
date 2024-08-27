import { RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated"
import { getDirectProps } from "./PDFViewUtils"
import { webview } from '@kit.ArkWeb';
import { util } from '@kit.ArkTS';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import PDFConstants from './PDFConstants'
import Logger from './Logger'

@Component
export struct RNPDFView {
  // 定义一个静态只读的常量，值为RNC.RNPDFView.NAME
  public static readonly NAME = RNC.RNPDFView.NAME
  // 定义一个RNComponentContext类型的属性ctx
  public ctx!: RNComponentContext
  // 定义一个数字类型的属性tag，初始值为1000
  public tag: number = 1000
  // 定义一个RNC.RNPDFView.DescriptorWrapper类型的私有状态属性descriptorWrapper，初始值为空对象
  @State private descriptorWrapper: RNC.RNPDFView.DescriptorWrapper = {} as RNC.RNPDFView.DescriptorWrapper
  // 定义一个RNC.RNPDFView.EventEmitter类型的私有属性eventEmitter，初始值为undefined
  private eventEmitter: RNC.RNPDFView.EventEmitter | undefined = undefined
  // 定义一个私有属性cleanUpCallbacks，类型为一个函数的数组，初始值为空数组
  private cleanUpCallbacks: (() => void)[] = []
  // 定义一个webview.WebviewController类型的属性controller，初始值为一个新的webview.WebviewController实例
  controller: webview.WebviewController = new webview.WebviewController()
  // 定义一个Resource类型的状态属性source，初始值为undefined
  @State source: Resource | undefined = undefined;
  // 定义一个WebResourceResponse类型的属性responseWeb，初始值为一个新的WebResourceResponse实例
  responseWeb: WebResourceResponse = new WebResourceResponse();
  // 定义一个Header类型的数组属性heads，初始值为一个空数组
  heads: Header[] = new Array();
  // 定义一个私有属性resource，类型为字符串或Resource，初始值为空字符串
  private resource: string | Resource = ''
  // 定义一个私有属性FILENAME，值为'/pdf.pdf'
  private FILENAME: string = '/pdf.pdf'
  // 定义一个状态属性animationOpacity，类型为数字，初始值为0
  @State animationOpacity: number = 0
  // 定义一个私有属性cleanupCommandCallback，类型为一个可能为空的函数，初始值为undefined
  private cleanupCommandCallback?: () => void = undefined

  /**
   * 当组件即将出现时的处理函数
   */
  aboutToAppear() {
    // 创建一个新的EventEmitter实例，并赋值给eventEmitter
    this.eventEmitter = new RNC.RNPDFView.EventEmitter(this.ctx.rnInstance, this.tag)
    // 调用onDescriptorWrapperChange方法，参数为通过tag找到的descriptorWrapper
    this.onDescriptorWrapperChange(this.ctx.descriptorRegistry.findDescriptorWrapperByTag<RNC.RNPDFView.DescriptorWrapper>(this.tag)!)
    // 将一个订阅函数添加到cleanUpCallbacks数组中
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (_descriptor, newDescriptorWrapper) => {
        // 当descriptorWrapper发生变化时，调用onDescriptorWrapperChange方法
        this.onDescriptorWrapperChange(newDescriptorWrapper! as RNC.RNPDFView.DescriptorWrapper)
      }
    ))
    // 调用registerCommandCallback方法，注册命令回调函数
    this.registerCommandCallback()
  }

  /**
   * 注册命令回调函数的方法
   */
  registerCommandCallback() {
    Logger.debug("registerCommandCallback startstart")
    // 注册命令回调函数，并将返回的清理函数赋值给cleanupCommandCallback
    this.cleanupCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: string[]) => {
        switch (command) {
          case "reload":
            try {
              // 尝试加载资源
              this.controller.loadUrl(this.resource)
            } catch (error) {
              // 如果加载失败，发送错误事件
              this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'error',
                { error: { message: error.message } })
            }
            break
          default:
            break
        }
      });
  }

  /**
   * 当descriptorWrapper发生变化时的处理函数
   * @param descriptorWrapper 变化后的descriptorWrapper
   */
  private onDescriptorWrapperChange(descriptorWrapper: RNC.RNPDFView.DescriptorWrapper) {
    Logger.debug("onDescriptorWrapperChange startstart")
    // 更新descriptorWrapper的值
    this.descriptorWrapper = descriptorWrapper
    // 调用renderContent方法
    this.renderContent()
  }

  /**
   * 获取直接属性的方法
   * @return 返回直接属性
   */
  private getDirectProps() {
    return getDirectProps(this.descriptorWrapper)
  }

  /**
   * 当组件即将消失时的处理函数
   */
  aboutToDisappear() {
    // 遍历cleanUpCallbacks数组，执行每个函数
    this.cleanUpCallbacks.forEach(cb => cb())
  }

  /**
   * 渲染内容的方法
   * 根据不同的资源类型，进行不同的处理
   * 如果资源类型是URL，直接将资源设置为URL
   * 如果资源类型是文件，根据文件来源，设置不同的文件路径
   * 如果资源类型是Base64，将Base64解码后的数据写入文件，并设置资源为文件路径
   * 如果在处理过程中出现错误，会抛出错误事件
   * @throws {BusinessError} 如果文件无法打开或者资源类型不被识别，会抛出错误
   */
  renderContent() {
    Logger.debug("renderContent startstart")
    // 如果支持透明度，进行动画

    // 如果输入不满足要求，直接返回
    if (!this.isRequiredInputSet()) {
      return
    }
    // 如果资源类型不被识别，抛出错误
    if (!this.isSupportedResourceType()) {
      const message = "resourceType:" + this.getDirectProps().resourceType + "not recognized"
      this.throwError(message)
      return;
    }
    // 如果资源类型是URL，直接将资源设置为URL
    if (this.isURLResource()) {
      this.resource = this.getDirectProps().resource
    } else if (this.isFileResource()) {
      try {
        const resource = this.getDirectProps().resource as string
        // 根据文件来源，设置不同的文件路径
        if (this.getDirectProps().fileFrom == 'files') {
          this.resource = this.ctx.uiAbilityContext.filesDir + '/' + resource
        } else if (this.getDirectProps().fileFrom == 'cache') {
          this.resource = this.ctx.uiAbilityContext.cacheDir + '/' + resource
        } else if (this.getDirectProps().fileFrom == 'temp') {
          this.resource = this.ctx.uiAbilityContext.tempDir + '/' + resource
        } else {
          // file selector /docs/storage/Users/currentUser/Download/
          if (!resource.startsWith('file')) {
            this.resource = 'file:/' + this.getDirectProps().resource
          } else {
            this.resource = resource
          }
        }
        // 打开文件
        let file = fs.openSync(this.resource,
          fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        // 文件无法打开，抛出错误事件
        this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'error',
          { error: { message: err.message } })
      }
    } else if (this.isBase64Resource()) {
      try {
        let filePath = this.ctx.uiAbilityContext.filesDir + this.FILENAME;
        let res = fs.accessSync(filePath);
        // 如果文件已存在，删除
        if (res) {
          fs.unlinkSync(filePath);
        }
        // 打开文件
        let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let base64Helper = new util.Base64Helper();
        let result = base64Helper.decodeSync(this.getDirectProps().resource).buffer;
        // 将解码后的数据写入文件
        fs.writeSync(file.fd, result)
        fs.closeSync(file)
        // 设置资源为文件路径
        this.resource = filePath
      } catch (error) {
        // 抛出错误事件
        this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'error',
          { error: { message: error.message } })
      }
    }
  }

  /**
   * 检查必要的输入是否已设置
   * @return {boolean} 如果必要的输入已设置，返回true，否则返回false
   */
  isRequiredInputSet(): boolean {
    Logger.debug("isRequiredInputSet start")

    // 获取直接属性
    if (this.getDirectProps().resource == 0) {
      // 如果资源值为0，则生成错误信息
      const errorMessage = "resource:" + this.getDirectProps().resource
      return false
    }
    return true
  }

  /**
   * 判断是否支持透明度
   * @return {boolean} 如果fadeInDuration存在，则返回true，否则返回false
   */
  isSupportedOpacity(): boolean {
    Logger.debug("isSupportedOpacity result:" + this.getDirectProps().fadeInDuration)
    return Boolean(this.getDirectProps().fadeInDuration)
  }

  /**
   * 判断资源类型是否被支持
   * @return {boolean} 如果是URL资源、Base64资源或者文件资源，则返回true，否则返回false
   */
  isSupportedResourceType(): boolean {
    return this.isURLResource() || this.isBase64Resource() || this.isFileResource()
  }

  /**
   * 判断是否为URL资源
   * @return {boolean} 如果资源类型为URL，则返回true，否则返回false
   */
  isURLResource(): boolean {
    return this.getDirectProps().resourceType === PDFConstants.RESOURCE_TYPE_URL
  }

  /**
   * 判断是否为Base64资源
   * @return {boolean} 如果资源类型为Base64，则返回true，否则返回false
   */
  isBase64Resource(): boolean {
    return this.getDirectProps().resourceType === PDFConstants.RESOURCE_TYPE_BASE64
  }

  /**
   * 判断是否为文件资源
   * @return {boolean} 如果资源类型为文件，则返回true，否则返回false
   */
  isFileResource(): boolean {
    return this.getDirectProps().resourceType === PDFConstants.RESOURCE_TYPE_FILE
  }

  /**
   * 抛出错误
   * @param {string} message - 错误信息
   */
  throwError(message: string) {
    this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'error',
      { error: { message: message } })
  }

  /**
   * 构建组件
   * @return {void}
   */
  build() {
    // 创建一个RNViewBase实例，传入上下文和标签
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      // 创建一个Column实例
      Column() {
        // 创建一个Web实例，传入资源和控制器
        Web({ src: this.resource, controller: this.controller })// 允许DOM存储访问
          .domStorageAccess(true)// 允许JavaScript访问
          .javaScriptAccess(true)// 允许文件访问
          .fileAccess(true)// 设置透明度，如果支持透明度则设置为动画透明度，否则设置为1
          .opacity(this.isSupportedOpacity() ? this.animationOpacity : 1)
          .overviewModeAccess(false)// 页面结束时触发事件
          .onPageEnd(() => {
            // 触发组件事件
            this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'load', {})
          })// 接收错误时触发事件
          .onErrorReceive((event) => {
            // 如果存在错误，触发组件事件
            if (event) {
              this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'error',
                { error: { message: event.error.getErrorInfo() } })
            }
          })
          .onAppear(() => {
            if (this.isSupportedOpacity()) {
              Logger.debug("isSupportedOpacity true")
              animateTo({
                duration: this.getDirectProps().fadeInDuration,
              }, () => {
                Logger.debug("animateTo startstart")
                this.animationOpacity = 1
              })
            }
          })// 滚动时触发事件
          .onScroll((event) => {
            // 触发组件事件
            this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, 'scrolled', { offset: event.yOffset })
          });
      }.width("100%").height("100%") // 设置宽度和高度为100%
      // 构建子组件
      this.ctx.wrappedRNChildrenBuilder.builder(this.ctx, this.tag)
    }
  }
}

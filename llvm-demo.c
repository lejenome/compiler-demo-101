#include <llvm-c/Core.h>
#include <stdlib.h>

int main()
{
	LLVMContextRef context = LLVMGetGlobalContext();
	LLVMModuleRef module = LLVMModuleCreateWithName("test-101");
	LLVMBuilderRef builder = LLVMCreateBuilder();
	// LLVMInt32Type()
	// LLVMFunctionType(rtnType, paramType, parmCnt, isVarArg)
	// LLVMAddFunction(module, name, functionType)
	LLVMTypeRef main = LLVMFunctionType(LLVMInt32Type(), NULL, 0, 0);
	LLVMValueRef mainFn = LLVMAddFunction(module, "main", main);
	LLVMBasicBlockRef mainBlk = LLVMAppendBasicBlock(mainFn, "entry");
	LLVMPositionBuilderAtEnd(builder, mainBlk);
	LLVMValueRef str =
	    LLVMBuildGlobalStringPtr(builder, "Hello World!", "str");
	LLVMTypeRef args[1];
	args[0] = LLVMPointerType(LLVMInt8Type(), 0);
	LLVMTypeRef puts = LLVMFunctionType(LLVMInt32Type(), args, 1, 0);
	LLVMValueRef putsFn = LLVMAddFunction(module, "puts", puts);

	LLVMBuildCall(builder, putsFn, &str, 1, "");

	LLVMBuildRet(builder, LLVMConstInt(LLVMInt32Type(), 0, 0));

	LLVMDumpModule(module);

	return 0;
}

class HttpErrorHandlerService {
  const HttpErrorHandlerService();

  String handleHttpErrorCode(int errorCode) {
    switch (errorCode) {
      case 1:
        return 'We couldn\'t find any questions for the selected options, please changes your criteria and try again';
      case 2:
        return 'Invalid request';
      case 3:
        return 'Session has not been started yet!';
      case 4:
        return 'No more questions found. try resetting your session.';
      default:
        return 'Unknown Error';
    }
  }
}
